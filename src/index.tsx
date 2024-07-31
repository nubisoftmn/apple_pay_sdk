import { NativeModules, Alert } from 'react-native';

const { BonumApplePay } = NativeModules;

export interface CardDetails {
  cardholderName: string;
  primaryAccountSuffix: string;
  paymentNetwork: string;
  primaryAccountIdentifier: string;
}

export interface NetworkDetails {
  url: string;
  method: string;
  header: string[];
  body: string;
}

export const presentAddPaymentPassViewController = async (
  cardDetails: CardDetails,
  networkDetails: NetworkDetails
): Promise<boolean> => {
  try {
    const success = await BonumApplePay.presentAddPaymentPassViewController(
      cardDetails,
      networkDetails
    );

    return success;
  } catch (error) {
    console.error('Failed to present Apple Wallet interface', error);
    Alert.alert('Error', 'Failed to present Apple Wallet interface');
    return false;
  }
};

export const getWalletInformation = async () => {
  try {
    const result = await BonumApplePay.retrieveWalletInformation();
    console.log(result);
    Alert.alert(result);
  } catch (error) {
    console.error('Error retrieving wallet information:', error);
    Alert.alert('Error: ' + error);
  }
};

export const checkIfCanAddPass = async () => {
  try {
    const canAddPass = await BonumApplePay.canAddSecureElementPassFunction();
    return canAddPass;
  } catch (error) {
    console.error('Error check', error);
  }
};

export const getPasses = async () => {
  try {
    const passes = await BonumApplePay.getAllPaymentPasses();
    if (passes.length === 0) {
      console.log('No cards added');
    } else {
      console.log('Get Passes:', passes);
      return passes;
    }
  } catch (error) {
    console.error('Failed to fetch', error);
    return [];
  }
};

export const getWatchPasses = async () => {
  try {
    const passes = await BonumApplePay.getAllWatchesPass();
    if (passes.length === 0) {
      console.log('No watchs added');
    } else {
      console.log('Get Watch Passes:', passes);
      return passes;
    }
  } catch (error) {
    console.error('Failed to fetch watch pass', error);
    return [];
  }
};

export const checkSecureElementPassExists = async (
  primaryAccountIdentifier: String
) => {
  try {
    const exists = await BonumApplePay.secureElementPassExists(
      primaryAccountIdentifier
    );
    console.log('Secure element pass baina:', exists);
    return exists;
  } catch (error) {
    console.error('Error Secure element pass:', error);
    throw error;
  }
};
