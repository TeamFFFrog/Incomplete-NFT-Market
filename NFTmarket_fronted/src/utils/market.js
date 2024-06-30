import { ethers } from 'ethers';
import ABI from '../contracts/Market.json';

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());

export async function buy(tokenId) {
    const result = await contract.buy(tokenId);
    console.log('buy', result.hash);
}

export async function change(tokenId, price) {
  const result = await contract.change(tokenId, price);
  console.log('change price', result.hash);
}

export async function cancel(tokenId) {
  const result = await contract.cancel(tokenId);
  console.log('cancel order', result.hash);
}

export async function getAllNFTs() {
  const result = await contract.getAllNFTs();
  console.log(result);
}

export async function getMyNFTs() {
  const result = await contract.getMyNFTs();
  console.log(result);
}

export async function getOrder(tokenId) {
  const result = await contract.orderOfId(tokenId);
  return {
    seller: result[0],
    tokenId: Number(result[1]),
    price: Number(result[2]) / 1e18,
  }
}
