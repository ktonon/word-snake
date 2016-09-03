import { Socket } from 'phoenix';

const socket = new Socket('/socket', {
  params: {
    token: window.userToken, // eslint-disable-line no-undef
  },
  logger: (kind, msg, data) => {
    console.log(`${kind}: ${msg}`, data); // eslint-disable-line no-console
  },
});

export default socket;
