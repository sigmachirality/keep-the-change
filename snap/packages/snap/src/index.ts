import type { OnRpcRequestHandler, OnTransactionHandler } from '@metamask/snaps-types';
import { heading, panel, text } from '@metamask/snaps-ui';

// Handle outgoing transactions.
export const onTransaction: OnTransactionHandler = async ({ transaction }) => {

  const result = await ethereum.request({
    method: 'wallet_invokeSnap',
    params: {
      snapId: 'TODO: LOL',
      request: {
        method: 'prompt-donation',
        params: transaction
      }
    }
  })

  return {
    content: panel([
      heading('Round up your transaction'),
      text(
        `As set up, you are paying 0 in gas fees for this transaction.`,
      ),
    ]),
  };
};

/**
 * Handle incoming JSON-RPC requests, sent through `wallet_invokeSnap`.
 *
 * @param args - The request handler args as object.
 * @param args.origin - The origin of the request, e.g., the website that
 * invoked the snap.
 * @param args.request - A validated JSON-RPC request object.
 * @returns The result of `snap_dialog`.
 * @throws If the request method is not valid for this snap.
 */
export const onRpcRequest: OnRpcRequestHandler = ({ origin, request }) => {
  switch (request.method) {
    case 'prompt-donation':
      const transaction = request.params;
      return snap.request({
        method: 'snap_dialog',
        params: {
          type: 'confirmation',
          content: panel([
            text(`Hello, **${origin}**!`),
            text('This custom confirmation is just for display purposes.'),
          ]),
        },
      });
    default:
      throw new Error('Method not found.');
  }
};
