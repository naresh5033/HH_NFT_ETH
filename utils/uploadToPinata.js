const pinataSDK = require("@pinata/sdk");
const fs = require("fs");
const path = require("path");

const pinataApiKey = process.env.PINATA_API_KEY || "";
const pinataApiSecret = process.env.PINATA_API_SECRET || "";
const pinata = new pinataSDK(pinataApiKey, pinataApiSecret);

async function storeImages(imagesFilePath) {
  const fullImagesPath = path.resolve(imagesFilePath);

  // Filter the files in case the are a file that in not a .png
  const files = fs
    .readdirSync(fullImagesPath)
    .filter((file) => file.includes(".png"));

  let responses = [];
  console.log("Uploading to IPFS");

  for (const fileIndex in files) {
    const readableStreamForFile = fs.createReadStream( //we ve to create a stream, whr we stream all the data inside of the imgs 
      `${fullImagesPath}/${files[fileIndex]}`
    );
    const options = {
      pinataMetadata: {
        name: files[fileIndex],
      },
    };
    try {
      await pinata
        .pinFileToIPFS(readableStreamForFile, options) //for our img stuff
        .then((result) => {
          responses.push(result);
        })
        .catch((err) => {
          console.log(err);
        });
    } catch (error) {
      console.log(error);
    }
  }
  return { responses, files };
}

async function storeTokenUriMetadata(metadata) {
  const options = {
    pinataMetadata: {
      name: metadata.name,
    },
  };
  try {
    const response = await pinata.pinJSONToIPFS(metadata, options);// for the metadata thing
    return response;
  } catch (error) {
    console.log(error);
  }
  return null;
}

module.exports = { storeImages, storeTokenUriMetadata };
