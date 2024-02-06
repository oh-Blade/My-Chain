const express = require("express");
const app = express();
const cors = require("cors");
const port = 3042;

app.use(cors());
app.use(express.json());
/**
 * private key:  7497b5ff9faf5eeb84522f8edfe67593d254e49842a4faad3abaa54b8f719339
public key:  048f5c96113dce004935f51cc41c66b8ec2ac06e2dbf57593e24b2b0e3d352e923441855ae865e3c03daf5d43747f7c7e0a1ae17ddff5fd25da18f5e30675d04a3
private key:  6ebecc2c9e6b8bad83339746baac1d30d8fb3ddcb1d68fe2568ccbfa09cb7200
public key:  041fa75d7c601d47f0e71ba6aa9bb8963c28a385e04453e6e7827c12fb75e7baf969fa537848f583f65c4940ec4b542b7e7fc30163068b9b85dd7a840b8e56a944
private key:  249ecff481ace13581a560dcac192f235539352760742086588e16dd663322ce
public key:  04f0245c08acc32410daf5831872c20c1b457f322290c2262daa8a8503e221cad8c875c5b0471798cec1872d60e8a385caed1aa79080e09b56a28dfc2f0d81c212
 */
const balances = {
  "048f5c96113dce004935f51cc41c66b8ec2ac06e2dbf57593e24b2b0e3d352e923441855ae865e3c03daf5d43747f7c7e0a1ae17ddff5fd25da18f5e30675d04a3": 100,
  "041fa75d7c601d47f0e71ba6aa9bb8963c28a385e04453e6e7827c12fb75e7baf969fa537848f583f65c4940ec4b542b7e7fc30163068b9b85dd7a840b8e56a944": 50,
  "04f0245c08acc32410daf5831872c20c1b457f322290c2262daa8a8503e221cad8c875c5b0471798cec1872d60e8a385caed1aa79080e09b56a28dfc2f0d81c212": 75,
};

app.get("/balance/:address", (req, res) => {
  const { address } = req.params;
  const balance = balances[address] || 0;
  res.send({ balance });
});

app.post("/send", (req, res) => {
  const { sender, recipient, amount } = req.body;

  setInitialBalance(sender);
  setInitialBalance(recipient);

  if (balances[sender] < amount) {
    res.status(400).send({ message: "Not enough funds!" });
  } else {
    balances[sender] -= amount;
    balances[recipient] += amount;
    res.send({ balance: balances[sender] });
  }
});

app.listen(port, () => {
  console.log(`Listening on port ${port}!`);
});

function setInitialBalance(address) {
  if (!balances[address]) {
    balances[address] = 0;
  }
}
