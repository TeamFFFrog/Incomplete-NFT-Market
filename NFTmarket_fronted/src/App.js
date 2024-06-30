import '../node_modules/antd/dist/reset.css';
import { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';

import UploadImage from './components/UploadImage';
import Navbar from './components/Navbar';
import UploadSuccess from './components/UploadSuccess';
import NFTGrid from './components/NFTGrid';
import NFTDetail from './components/NFTDetail';

function App() {
  const [walletAddress, setWallet] = useState("");

  useEffect(() => {
    addWalletListener();
  }, []);

  function addWalletListener() {
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", (accounts) => {
        if (accounts.length > 0) {
          setWallet(accounts[0].slice(0, 8)); // 只显示前8位
        } else {
          setWallet("");
        }
      });
    }   
  }

  const getWalletAddress = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setWallet(accounts[0].slice(0, 8)); // 只显示前8位
      } catch (error) {
        console.error('Error connecting to wallet:', error);
      }
    }
  };

  return (
    <div id="container">
      <Router>
        <Navbar onConnectWallet={getWalletAddress} address={walletAddress} />
        <Routes>
          <Route path="/create-nft" exact element={<UploadImage address={walletAddress}/>} />
          <Route path="/success" element={<UploadSuccess />} />
          <Route path="/" element={<NFTGrid />} />
          <Route path="/nft-detail/:tokenId" element={<NFTDetail />} />
        </Routes>
      </Router>
    </div> 
  );
}

export default App;

