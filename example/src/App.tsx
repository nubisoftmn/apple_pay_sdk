import React from 'react';
import { SafeAreaView, StyleSheet, TouchableOpacity, Text } from 'react-native';
import { addCardToAppleWallet } from 'react-native-bonum-apple-pay';

const cardDetails = {
  cardholderName: 'John Doe',
  primaryAccountSuffix: '1234',
  // Add other necessary details
};

const App: React.FC = () => {
  const handleAddToWallet = () => {
    addCardToAppleWallet(cardDetails);
  };

  return (
    <SafeAreaView style={styles.container}>
      <TouchableOpacity style={styles.button} onPress={handleAddToWallet}>
        <Text style={styles.buttonText}>Add to Apple Wallet</Text>
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

export default App;
