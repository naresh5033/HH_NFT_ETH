## HH_NFT

We'll go thru creating 3 types of nfts\

1. Basic NFT
2. Random IPFS hosted NFT
   - That uses VRF Randomness to generate a unique NFT
3. Dynamic SVG NFT (hosted 100% on-CHAIN)
   - Uses Price feed to be dynamic

## HH set up

`yarn add --dev @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers @nomiclabs/hardhat-etherscan @nomiclabs/hardhat-waffle chai ethereum-waffle hardhat hardhat-contract-sizer hardhat-deploy hardhat-gas-reporter prettier prettier-plugin-solidity solhint solidity-coverage dotenv @typechain/ethers-v5 @typechain/hardhat @types/chai @types/node ts-node typechain typescript`

## Basic NFT

This Basic NFT is an ERC721 contract (the name is the doggie and the symbol is DOG)\
Whoever calls the mint fn (\_safeMint()) will get the token.\
The tokenURI will ve the json (is a metadata) for our minted token.
This json consist of an image URL which will point our image, this url can be hosted on the on-chain or off-chain or wherever. \
In our case i hosted them in IPFS.\

Once we deployed our contract in the testnet, and in the opensea testnet we can see that NFT token PUG img

## Random IPFS NFT

This RandomNft contract is a VRFConsumerBaseV2.sol, ERC721.sol, ERC721URI.sol, ownable.sol\

When we make a mint(we ve to pay for the mint) and NFT, we'l get a chainlink's VRF call to get us a random number. \ `yarn add @chainlink/contracts`
Using that number, we'll get a random NFT.\
The Random nft will be a Pug, shiba Inu, st. Bernard.\
we'll make them based on the rareness ex. the pub will be super rare, the shiba inu will be sorta rare, and the st. bernard will be common one.\

As we ve to pay for mint then only the owner of the nft can withdraw the amt that we paid.

## Mapping chainlink VRF Requests

when we call the requestNft(), it will send 2 tx, it will request and fullfillrand() --> which has the \_safeMint() so the owner will be the chainlink node that calls the fulfilrand(). we don't wana do that.\
So we wana create a mapping b/w the req id and whoever call that reqnfts --> address dogOwner = s_requestIdToSender[requestId]; \
The rarity of the dogs was implemented in the getChanceArray() --> array represents diff chances of the dogs.\
From the ERC 721 extn (ERC721storageURI) --> we called the \_setTokenURI() --> which will updates our token's URI to whatever we set it as.\
With that we'll ve a programatically provable randomNft with diff randomness for diff one of these NFTs

## IPFS, Pinata, NFT.Storage

We need to upload our image(dogs) in the IPFS and get the Hashes, we gon pin to our node.
Only pinning to our node won't be enough so there are couple of ways we can pin.\

1. Pinata service --> we can pin to pinata service (we 'l use pinata)
2. NFT.Storage(free storage for NFTs) --> uses file coin N/w on the backend to pin our data, this is also one of the most persistant way to keep our data up

We've the scripts to upload our nft in both pinata and nft.storage, in the utils dir -> uploadTONftStorage.js and uploadToPinata.js

we used pinata to upload our nft, `yarn add @pinata/sdk` --> and pinning by pinFileToIpfs(Images) and pinJSONToIpfs(metadata)

However hosting in this pinata service has their own pros and cons.\
pros : cheap \
cons: someone has to pin our data

## Dynamic SVG NFT

Pros: Our Data is On-chain, and we don't need to worry about somebody pinnig our data.
Cons : Much more expensive for storig our data, so for this part instead of pngs im gona use svgs (scaled vector graphics).\

This we gon make it Dynamic the SVG will change based on the data that stored on the On-chain Ex. " If the price of the Eth is Above X - Happy face, or else Frowny face."\
So our NFT will change based on the real world parameter.\

This DynamicSvgNft is ERC721.sol, this will ve mint(), store our svg info somewhere and need to ve some logic to say show X img or show Y Img.

## Base64

We can actually encode any svg to a base64 img url, we can convert the svg code into img uri --> svgToImgUri()

`yarn add --dev base64-sol` --> to encode and decode base 64.\

## low Svg or High SVg

we'll let the minters to choose the val b/w the vals they wana use(we'l assign the each nft their high val),

Then in the \_tokenURI(), we'll set if the price is >= tokenidtoHighval then we'll use high svg otherwise the low svg

## Mint

In the deploy scripts we ve mint.js for each of our contract to mint the nft.\

Note: while deploying in the testnet we shouldn't call the mint fn, coz we need to add our consumer to the VRF before we mint.\

`yarn hh deploy --network goerli --tags main`

Basic nft --> "0xF305Dd14bD6dFb855aE886BaFB10809f3BD58090" \
RandomIpfs NFT --> "0xb900C5f7DE8B0AbCcE10D07ea7d6Dc790ebe8Da5" \
Dynamic Svg --> "0x3A6B7f54AE1B7cdC7806c9Dc44a455FB8f029c47" \

Add this randipf nft addr as our consumer in our vrf.chain.link.\
After added that addr now we can mint (04-mint.js/deploy) one nft from each one those above contracts.\
`yarn hh deploy --network goerli --tags mint` \

## openSea Testnet

after we minted
Grab the Dynamic svg addr(all the 3 addrs) and goto opensea testnet, search it we can see our nft there similarly we can see all our other nfts.\

we can also check in the goerli etherscan -> read contract -> token Uri -> indx 0 -> our minted nft Uri. \
