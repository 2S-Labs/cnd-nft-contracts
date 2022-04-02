const hre = require('hardhat')

async function main() {
  const devAddress = ''
  const baseURI = ''

  const CndAsset = await hre.ethers.getContractFactory('ClonesNeverDieAsset')
  const cndAsset = await CndAsset.deploy(devAddress, baseURI)

  await cndAsset.deployed()

  console.log('ClonesNeverDieAsset deployed to:', cndAsset.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
