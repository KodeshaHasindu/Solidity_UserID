const {ethers} = require("hardhat");
//console.log(ethers);

async function main(){
    

const UserId = await ethers.getContractFactory("UserId");
const myTest = await UserId.deploy();

await myTest.deployed();

console.log('userID deployed');

}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.log(error);
    process.exitCode =1;
});
