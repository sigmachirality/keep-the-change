import type { BaseProvider } from "@metamask/providers";
import type { PlasmoCSConfig } from "plasmo";
export const config: PlasmoCSConfig = {
  matches: ["<all_urls>"],
  world: "MAIN"
}

const proxyHandler: ProxyHandler<BaseProvider["request"]> = {
  apply: (target, thisArg, argumentsList) => {
    const [requestArgs] = argumentsList;
    const { method } = requestArgs;
    console.log(method, argumentsList);
    return Reflect.apply(target, thisArg, argumentsList);
  }
};

function injectProxy() {
  const { ethereum } = window;
  if (!ethereum) return;
  Object.defineProperty(ethereum, "request", {
    value: new Proxy(ethereum.request, proxyHandler)
  });

  console.log("injected", ethereum)
  clearInterval(injectInterval);
}

const injectInterval = setInterval(injectProxy, 100);

