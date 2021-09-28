import config from "./config";
import {
  mainnet,
  OpticsContext,
  OpticsMessage,
  OpticsStatus,
} from "@optics-xyz/multi-provider";
import {
  AnnotatedLifecycleEvent,
  MessageStatus,
} from "@optics-xyz/multi-provider/dist/optics";

mainnet.registerRpcProvider("celo", config.CeloRpc);
mainnet.registerRpcProvider("ethereum", config.EthereumRpc);
mainnet.registerRpcProvider("polygon", config.PolygonRpc);

const STATUS_TO_STRING = {
  [MessageStatus.Dispatched]: "Dispatched on Home",
  [MessageStatus.Included]: "Included in Home Update",
  [MessageStatus.Relayed]: "Relayed to Replica",
  [MessageStatus.Processed]: "Processed",
};

const input: TraceInput[] = [
  {
    chain: "polygon",
    transactionHash:
      "0xb1946cde07ad1741f4b6574ea0cf43f3020a1a1764052405ebeb5c0729286f4b",
    messageHash:
      "0x5ef2c496b77ec7d0433b5b2a6a5bf760cf26952e447078405ddc9573f63a156c",
    leafIndex: 428,
  },
];

traceMany(input).then(() => {
  console.log("DONE!");
});

async function traceMany(inputs: TraceInput[]) {
  for (let input of inputs) {
    const { chain, transactionHash } = input;
    await traceTransfer(mainnet, chain, transactionHash);
  }
}

interface TraceInput {
  chain: string;
  transactionHash: string;
  messageHash?: string;
  leafIndex?: number;
}

interface QuietEvent {
  event: string;
  domainName: string;
  blockNumber: number;
  transactionHash: string;
}

function quietEvent(
  context: OpticsContext,
  lifecyleEvent: AnnotatedLifecycleEvent
): QuietEvent {
  // TODO: transform nameOrDomain to human readable
  // TODO: add link to block explorer????
  const { event, domain } = lifecyleEvent;
  const domainName = context.resolveDomainName(domain);
  if (!domainName) {
    throw new Error("I have no name");
  }
  return {
    event: lifecyleEvent.name!,
    domainName,
    blockNumber: event.blockNumber,
    transactionHash: event.transactionHash,
  };
}

function printStatus(context: OpticsContext, opticsStatus: OpticsStatus) {
  const { status, events } = opticsStatus;
  const printable = {
    status: STATUS_TO_STRING[status],
    events: events.map((event) => quietEvent(context, event)),
  };
  console.log(JSON.stringify(printable, null, 2));
}

async function traceTransfer(
  context: OpticsContext,
  origin: string,
  transactionHash: string
) {
  console.log(`Trace ${transactionHash} on ${origin}`);

  const message = await OpticsMessage.singleFromTransactionHash(
    context,
    origin,
    transactionHash
  );
  const status = await message.events();

  printStatus(context, status);
}
