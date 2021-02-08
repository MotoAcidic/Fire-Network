require('dotenv').config({ path: '../.env' })

const Auction = artifacts.require('./Auction.sol');
const Staking = artifacts.require('./Staking.sol');
const ForeignSwap = artifacts.require('./ForeignSwap.sol');
const BPD = artifacts.require('./BPD.sol');
const SubBalances = artifacts.require('./SubBalances.sol');
const Token = artifacts.require('./Token.sol');

module.exports = async function (deployer, network, accounts) {
        return deployer.then(async () => {

                const {
                    SETTER_ADDRESS,
                    SWAP_ADDRESS,
                    TEAM_ADDRESS,
                    DEV_ADDRESS,
                    UNI_ADDRESS,
                    TOKEN_NAME,
                    TOKEN_SYMBOL,
                } = process.env;

                if (SETTER_ADDRESS == null) {
                    throw 'Setter address not found. Aborting'
                }
                if (SWAP_ADDRESS == null) {
                    throw 'Setter address not found. Aborting'
                }
                if (TEAM_ADDRESS == null) {
                    throw 'Setter address not found. Aborting'
                }
                if (DEV_ADDRESS == null) {
                    throw 'Setter address not found. Aborting'
                }
                if (UNI_ADDRESS == null) {
                    throw 'Setter address not found. Aborting'
                }
                if (TOKEN_NAME == null) {
                    throw 'Token name parameter not found. Aborting'
                }
                if (TOKEN_SYMBOL == null) {
                    throw 'Token symbol parameter not found. Aborting'
                }

                console.log('Setter address: ', SETTER_ADDRESS);
                console.log('Setter address: ', SWAP_ADDRESS);
                console.log('Setter address: ', TEAM_ADDRESS);
                console.log('Setter address: ', DEV_ADDRESS);
                console.log('Setter address: ', UNI_ADDRESS);
                console.log('Token name: ', TOKEN_NAME);
                console.log('Token symbol: ', TOKEN_SYMBOL)

                // DEPLOY TOKEN
                const token = await deployer.deploy(
                    Token,
                    TOKEN_NAME,
                    TOKEN_SYMBOL,
                    SETTER_ADDRESS,
                    SWAP_ADDRESS,
                    TEAM_ADDRESS,
                    DEV_ADDRESS,
                    UNI_ADDRESS
                )

                // DEPLOY AUCTION
                const auction = await deployer.deploy(Auction)

                // DEPLOY STAKING
                const staking = await deployer.deploy(Staking)

                // DEPLOY SWAP
                const foreignSwap = await deployer.deploy(ForeignSwap, SETTER_ADDRESS);

                // DEPLOY BPD
                const bpd = await deployer.deploy(BPD, SETTER_ADDRESS);

                // DEPLOY SUBBALANCES
                const subBalances = await deployer.deploy(SubBalances, SETTER_ADDRESS)

                console.log('')
                console.log('Deployment completed.')
                console.log('Token address:', token.address);
                console.log('Auction address:', auction.address);
                console.log('Staking address:', staking.address);
                console.log('Foreign Swap address: ', foreignSwap.address);
                console.log('BPD address: ', bpd.address);
                console.log('SubBalances address:', subBalances.address);

                console.log('')
                console.log('-------')
                console.log('Code to paste in .env file for init:')
                console.log('-------')
                console.log('TOKEN_ADDRESS='+ token.address)
                console.log('AUCTION_ADDRESS=' + auction.address);
                console.log('STAKING_ADDRESS=' + staking.address);
                console.log('FOREIGN_SWAP_ADDRESS=' + foreignSwap.address);
                console.log('BPD_ADDRESS=' + bpd.address);
                console.log('SUBBALANCES_ADDRESS=' + subBalances.address);
                console.log('')
        })
}