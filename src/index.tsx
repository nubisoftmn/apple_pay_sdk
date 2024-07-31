import { NativeModules } from 'react-native';

const { BonumApplePay } = NativeModules;

export interface CardDetails {
  cardholderName: string;
  primaryAccountSuffix: string;
  paymentNetwork: string;
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
): Promise<void> => {
  try {
    await BonumApplePay.presentAddPaymentPassViewController(
      cardDetails,
      networkDetails
    );
    console.log('Apple Wallet interface presented successfully');
  } catch (error) {
    console.error('Failed to present Apple Wallet interface', error);
  }
};
