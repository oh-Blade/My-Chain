import "../styles/globals.css";
import "@rainbow-me/rainbowkit/styles.css";

import { getDefaultWallets, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { configureChains, createClient, WagmiConfig } from "wagmi";
import {
	mainnet,
	polygon,
	optimism,
	arbitrum,
	goerli,
	polygonMumbai,
	optimismGoerli,
	arbitrumGoerli,
} from "wagmi/chains";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { publicProvider } from "wagmi/providers/public";
import MainLayout from "../layout/mainLayout";

const { chains, provider } = configureChains(
	[
		mainnet,
		goerli,
		polygon,
		polygonMumbai,
		optimism,
		optimismGoerli,
		arbitrum,
		arbitrumGoerli,
	],
	[publicProvider({ apiKey: process.env.ALCHEMY_API_KEY }), publicProvider()]
);

const { connectors } = getDefaultWallets({
	appName: "nft-gallery",
	projectId: "76eb34b753141ca21a3d8449ff11ac01",
	chains,
});

const wagmiClient = createClient({
	autoConnect: false,
	connectors,
	provider,
});

export { WagmiConfig, RainbowKitProvider };
function MyApp({ Component, pageProps }) {
	return (
		<WagmiConfig client={wagmiClient}>
			<RainbowKitProvider
				modalSize="compact"
				initialChain={process.env.NEXT_PUBLIC_DEFAULT_CHAIN}
				chains={chains}
			>
				<MainLayout>
					<Component {...pageProps} />
				</MainLayout>
			</RainbowKitProvider>
		</WagmiConfig>
	);
}

export default MyApp;
