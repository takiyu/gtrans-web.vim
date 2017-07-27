#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import pickle

try:
    import asyncio
except ImportError:
    try:
        import trollius as asyncio
    except ImportError:
        print('Error: Use python 3.5 or install `trollius` package')
        exit(0)

import gtransweb

# Global driver
driver = gtransweb.create_driver()


# Translation server
class GtransServerProtocol(asyncio.Protocol):

    def connection_made(self, transport):
        # Save current connection
        self.transport = transport
        # Print
        print('New connection [{}:{}]'.format(*self._get_client_info()))

    def data_received(self, data):
        # Deserialize received data
        src_lang, tgt_lang, src_text = pickle.loads(data)

        # Access to translation page
        tgt_text = gtransweb.gtrans_search(driver, src_lang, tgt_lang,
                                           src_text)

        # Send serialized result
        data = pickle.dumps(tgt_text, protocol=2)
        self.transport.write(data)

    def connection_lost(self, exc):
        # Close connection
        self.transport.close()
        # Print
        print('End connection [{}:{}]'.format(*self._get_client_info()))

    def _get_client_info(self):
        client_address, client_port = self.transport.get_extra_info('peername')
        return client_address, client_port


if __name__ == '__main__':
    # Argument (vim mode is not available because of vimproc call)
    parser = argparse.ArgumentParser(description='gtrans-web')
    parser.add_argument('--port', type=int, default=23148,
                        help='Port number in `alone` mode')
    args = parser.parse_args()

    # Port number
    port = args.port

    # Create event loop
    event_loop = asyncio.get_event_loop()

    # Create and run a translation server
    factory = event_loop.create_server(GtransServerProtocol, 'localhost', port)
    server = event_loop.run_until_complete(factory)

    try:
        # Start
        event_loop.run_forever()
    except KeyboardInterrupt:
        pass

    # Exit
    server.close()
    event_loop.run_until_complete(server.wait_closed())
    event_loop.close()

    # Close driver
    driver.close()
