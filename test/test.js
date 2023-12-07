const { expect } = require("chai");

describe("UserId Contract", function () {
  let userIdContract;
  let owner;
  let userAddress;

  beforeEach(async () => {
    // Deploy the contract before each test
    const UserId = await ethers.getContractFactory("UserId");
    userIdContract = await UserId.deploy();
    await userIdContract.deployed();

    // Get accounts from Hardhat network
    [owner, userAddress] = await ethers.getSigners();
  });

  it("should create a user and verify existence", async function () {
    // Create a user
    await userIdContract.createUserId(userAddress.address, "John", "Doe", 1990, 1, 1, "Country");

    // Verify existence
    const isUserVerified = await userIdContract.isVerified(userAddress.address);
    expect(isUserVerified).to.equal(true);
  });

  it("should verify location", async function () {
    // Create a user
    await userIdContract.createUserId(userAddress.address, "John", "Doe", 1990, 1, 1, "Country");

    // Verify location
    const isLocationVerified = await userIdContract.locationVerified(userAddress.address, "Country");
    expect(isLocationVerified).to.equal(true);
  });

  it("should verify age limit", async function () {
    // Create a user
    await userIdContract.createUserId(userAddress.address, "John", "Doe", 2000, 1, 1, "Country");

    // Verify age limit (assuming 18 years)
    const tx = await userIdContract.verifyAgeLimit(userAddress.address, 18);

    // Check if the AgeVerified event is emitted
    await expect(tx)
        .to.emit(userIdContract, "AgeVerified")
        .withArgs(true);

    // Check if the age is verified
    const user = await userIdContract.UserStruct(userAddress.address);
    expect(user.ageVerified).to.equal(true);
});


  it("should not allow creating duplicate users", async function () {
    // Create a user
    await userIdContract.createUserId(userAddress.address, "John", "Doe", 1990, 1, 1, "Country");

    // Try creating the same user again
    await expect(
      userIdContract.createUserId(userAddress.address, "John", "Doe", 1990, 1, 1, "Country")
    ).to.be.revertedWith("User already exists and is verified");
  });
});
