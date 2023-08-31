use std::{env, sync::Arc};

use ethers::{types::{H160, TransactionRequest, U256, H256}, signers::{LocalWallet, Signer}, providers::{Http, Provider}, prelude::SignerMiddleware};
use tokio::task::JoinSet;
use warp::{Filter, Reply};
use serde::{Deserialize, Serialize, de};
use anyhow::Result;

use crate::bindings::donatooor::Donatooor;

mod bindings;

#[tokio::main]
async fn main() {
    dotenv::dotenv().ok();

    let post_route = warp::post()
        .and(warp::path("api"))
        .and(warp::path("tx"))
        .and(warp::body::json()) // This expects JSON in the request body
        .and_then(handle_tx_request); // Using and_then to work with async functions

    // Combine routes and start the server
    let routes = post_route;

    warp::serve(routes).run(([127, 0, 0, 1], 3030)).await;
}

// Define an async function to handle the transaction request
async fn handle_tx_request(data: TxInfo) -> Result<impl warp::Reply, warp::Rejection> {
    println!("Received data: {:?}", data);

    // Call the async function and await its result
    let tx_hash = get_tx(data).await.unwrap();

    // Create a TxResponse
    let tx_response = TxResponse {
        tx_hash: format!("{:?}", tx_hash),
    };

    // Reply with the JSON data
    Ok(warp::reply::json(&tx_response))
}


async fn get_tx(tx_info: TxInfo) -> Result<H256> {
    let p_key = env::var("PRIVATE_KEY")?.parse::<LocalWallet>()?;
    let provider = Provider::try_from(env::var("PROVIDER")?)?;
    let client = Arc::new(SignerMiddleware::new(provider, p_key));
    let donatooor = Donatooor::new("client".parse::<H160>()?, client);

    let platform = tx_info.platform as u8;
    let from = tx_info.from;
    let token_address = tx_info.token_info.address;
    let amount = tx_info.token_info.amount;
    let to = tx_info.to;
    let pool_id = tx_info.pool_id;

    let tx = donatooor.donate(platform, from, token_address, amount.into(), to, pool_id).send().await?.tx_hash();

    Ok(tx)
}

#[derive(Deserialize, Debug)]
struct TxInfo {
    token_info: TokenInfo,
    platform: Platform,
    from: H160,
    to: H160,
    #[serde(deserialize_with = "deserialize_u256")]
    pool_id: U256,
}

#[derive(Deserialize, Debug)]
struct TokenInfo {
    address: H160,
    amount: u128,
}

#[derive(Deserialize, Debug)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
enum Platform {
    Endaoment,
    Gitcoin,
}

#[derive(Serialize, Deserialize, Debug)]
struct TxResponse {
    tx_hash: String,
}

/// Helper function to convert a decimal string to a U256.
fn deserialize_u256<'de, D>(deserializer: D) -> Result<U256, D::Error>
where
    D: de::Deserializer<'de>,
{
    let val = String::deserialize(deserializer)?;
    U256::from_dec_str(&val).map_err(de::Error::custom)
}