import { ethers } from "hardhat";

async function main() {
    const deployer = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer);

    const ContractFactory = await ethers.getContractFactory("SelfToken");
    const contract = await ContractFactory.deploy("vASD", "vASD");

    await contract.deployed();

    contract.mint(1000);

    contract.approve("0x3129b0f5baaa917A25D6ED84Db35Fbc9fA2dD8C3", 1000 * 10 ** 18);

    contract.allowance(contract.address, "0x3129b0f5baaa917A25D6ED84Db35Fbc9fA2dD8C3").then((data) => {
        console.log(data);
    });

    console.log("YourContractName deployed to:", contract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

