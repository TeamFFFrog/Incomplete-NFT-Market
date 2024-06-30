import React from 'react';
import { Link } from 'react-router-dom';
import './Navbar.css'; // 导入 Navbar 的样式

function Navbar({ onConnectWallet, address }) {
  return (
    <div className="navbar">
      <div className="navbar-brand">NFT Market</div>
      <div className="navbar-menu">
        <Link to="/">Home</Link>
        <Link to="/create-nft">Create</Link>
        <button className="connect-wallet-button" onClick={onConnectWallet}>
          {address ? `Connected: ${address}` : 'Connect Wallet'}
        </button>
      </div>
    </div>
  );
}

export default Navbar;
