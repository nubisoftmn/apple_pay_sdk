# react-native-bonum-apple-pay

A React Native module by Bonum for adding cards to Apple Wallet. This package provides an easy-to-use interface for integrating Apple Wallet functionality into your React Native applications, allowing users to add payment cards directly to their Apple Wallet from within the app.

## Installation

```sh
npm install react-native-bonum-apple-pay
```

## Usage


Using the correct Apple wallet button, if you are not using the correct way, it will decline it from Apple.

Official site of [Add to Apple Wallet Guidelines](https://developer.apple.com/wallet/add-to-apple-wallet-guidelines/)


```js

import { CardDetails, NetworkDetails, presentAddPaymentPassViewController } from 'react-native-bonum-apple-pay';

// ...


// Info of the Wallet display 

const cardDetails: CardDetails = {
  cardholderName: 'bonum', // Card holder info to display in wallet dialog
  primaryAccountSuffix: '1234', // Last 4 digits of the card to display in wallet dialog
  paymentNetwork: 'masterCard', // Type of card if it is MasterCard  type it masterCard if it is Visa it is just visa
};


// Your Rest Api Request

const networkDetails: NetworkDetails = {
  url: "",
  method: '',
  header: ["Content-Type: application/json", "Authorization: Bearer ${token} "],
  body: JSON.stringify({
   // Your body's data
  }),
};



const App: React.FC = () => {
  
  const handlePresentWallet = () => {
    presentAddPaymentPassViewController(cardDetails, networkDetails);
  };

  // This example is not using add to apple wallet button

  return (
    <SafeAreaView style={styles.container}>
      <TouchableOpacity style={styles.button} onPress={handlePresentWallet}>
        <Text style={styles.buttonText}>Show Apple Wallet</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
  },
});



```


## License

MIT

Made by [Bonum The Future of Payment](https://www.bonum.mn/)


