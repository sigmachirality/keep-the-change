import React, { useEffect, useState } from "react";
import { useStorage } from "@plasmohq/storage/hook"
import Axios from 'axios';
import {
  GeistProvider,
  CssBaseline,
  Grid,
  Badge,
  Text,
  AutoComplete
} from '@geist-ui/core'
import { EndaomentSdkApi, NdaoSdkOrg } from '@endaoment/sdk';
import { formatGwei, hexToBigInt, hexToNumber, parseEther } from 'viem';
import "../style.css"
import { format } from "path";

const endaomentSDK = new EndaomentSdkApi()

function DeltaFlyerPage() {
  const [loading, setLoading] = useState(true);
  const [searchedEntities, setSearchedEntities] = useState<NdaoSdkOrg[]>([]);
  const [selected, setSelected] = useState<NdaoSdkOrg>()
  const [gasUSDValue, setGasUSDValue] = useState(0);
  const [gas] = useStorage<`0x${string}`>("message", '0x0')

  useEffect(() => {
    Promise.all([
      Axios.get(`https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd`),
      Axios.post(`https://gateway.tenderly.co/public/goerli`, {"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id": 1 })
    ]).then(([{ data: coingeckoData }, { data: gasFee }]) => {
      const unitsOfGas = hexToNumber(gas);
      console.log(gasFee?.result, formatGwei(hexToBigInt(gasFee?.result)))
      const baseFee = Number(formatGwei(hexToBigInt(gasFee?.result)));
      const USDBaseTokenPrice = coingeckoData?.ethereum?.usd;
      setGasUSDValue(unitsOfGas * baseFee)
      console.log(baseFee, unitsOfGas)
    })
  }, [gas])

  useEffect(() => {
    endaomentSDK.searchOrgs().then(res => {
      setSelected(res[0])
      setLoading(false)
    })
  }, [])

  const handleSearch = async (currentValue: string) => {
    setLoading(true);
    setSearchedEntities(await endaomentSDK.searchOrgs({ searchTerm: currentValue }));
    setLoading(false);
  };

  const handleSelect = async (selectedValue: string) => {
    setLoading(true);
    setSelected((await endaomentSDK.searchOrgs({ searchTerm: selectedValue}))?.[0])
    setLoading(false);
  }

  return (
    <GeistProvider>
      <CssBaseline />

      <Grid.Container gap={2} justify="center">
        <Grid xs={24} justify="center">
          <Text h2 className='mt-8 text-center'>Keep the Change!</Text>
        </Grid>
        <Grid xs={24} padding='2em' paddingTop={0} justify="center">
          <AutoComplete
            width="100%"
            searching={loading}
            placeholder='Search for an org'
            onSearch={handleSearch}
            onSelect={handleSelect}
            options={searchedEntities.map(org => (
              <AutoComplete.Option value={org.name}>
                <Grid.Container marginBottom='.5em' marginTop='.5em'>
                  <Grid xs={24}><Text span b font="1.2rem">{org.name}</Text></Grid>
                  <Grid.Container xs={24}>
                    <Grid xs={4}>{org.contractAddress && <Badge type="success">Deployed</Badge>}</Grid>
                    <hr />
                  </Grid.Container>
                </Grid.Container>
              </AutoComplete.Option>
            ))}
          />
        </Grid>
      </Grid.Container>
      <br />
      {gasUSDValue}$
    </GeistProvider>
  )
}

export default DeltaFlyerPage