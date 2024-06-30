import { ethers } from 'ethers';
import MyNFTABI from '../contracts/ERC721.json';

async function main() {
  let provider = new ethers.BrowserProvider(window.ethereum)
  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  let account = await provider.getSigner();

  const contract = new ethers.Contract(contractAddress, MyNFTABI, account);
  const result = await contract.totalSupply();
  await contract.safeMint('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', 'https://ipfs.io/ipfs/QmZ4tj')
  console.log(result.toString());
}


export default main;