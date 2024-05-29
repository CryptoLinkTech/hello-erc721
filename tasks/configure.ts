import { task } from "hardhat/config";
const chainsConfig = require('@vialabs-io/contracts/config/chains');
const networks = require("../networks-testnet.json");
const fs = require('fs');

task("configure", "")
	.addOptionalParam("signer", "Custom signer (private key)")
	.addOptionalParam("provider", "Custom provider RPC url")
	.setAction(async (args, hre:any) => {
		const ethers = hre.ethers;
		const [deployer] = await ethers.getSigners();

		let signer = deployer;
		if (args.signer) signer = new ethers.Wallet(args.signer, new ethers.providers.JsonRpcProvider(args.provider));
		
		let addresses = [];
		let chainids = [];
		let confirmations=[];
		for(let x=0; x < networks.length; x++) {
			const helloERC20 = require(process.cwd()+"/deployments/"+networks[x]+"/HelloERC721.json");
			const chainId = fs.readFileSync(process.cwd()+"/deployments/"+networks[x]+"/.chainId").toString();
			addresses.push(helloERC20.address);
			chainids.push(chainId);
			confirmations.push(1);
		}
	
		console.log('setting remote contract addresses .. CLT message address:', chainsConfig[hre.network.config.chainId].message);
		const helloERC721 = await ethers.getContract("HelloERC721");
		await (await helloERC721.configureClient(chainsConfig[hre.network.config.chainId].message, chainids, addresses, confirmations)).wait();
	});
