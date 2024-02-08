# DemoFinances
Finances with Chart
# DemoFinances

This repository contains the source code for a finance management app called DemoFinances. The app is built using Swift and includes various features for handling transactions, fetching data from an API, and presenting financial information with capability to input entries.

## Code Structure

### DashboardPresenter.swift

The `DashboardPresenter` class acts as a presenter for the Dashboard view controller (`DashBoardVC`). It handles data fetching, transaction submission, and interactions with the view. Key functions include `fetchData`, `submitTransaction`, and methods for managing the calendar view and entry popup.

### DashboardViewModel.swift

The `DashboardViewModel` class is responsible for managing the data related to transactions. It includes functions for fetching data from an API, filtering transactions for a selected date range, and calculating balance entries.

### TransactionModel.swift

The `TransactionElement` struct represents a financial transaction, and the `TransactionInput` struct is used for encoding transaction data for submission.

### Date+Extensions.swift

The `Date` extension provides various utility functions for working with dates, such as converting dates to strings, adding time intervals, and calculating differences between dates.

### UIColor+Extensions.swift

The `UIColor` extension allows for easy creation of color instances from hex codes.

### UIView+Extensions.swift

The `UIView` extension provides additional inspectable properties for customizing the appearance of views in Interface Builder.

### APIService.swift

The `APIService` class handles fetching and submitting transactions to a specified API endpoint. It includes functions for fetching transaction data (`fetchData`) and submitting transactions (`submitTransaction`).

## Usage

To use this code in your own project, you can clone the repository and integrate the provided Swift files into your Xcode project. Make sure to update the API endpoint in `APIService.swift` to match your backend and add dependencies.

Feel free to customize and extend the code according to your project requirements.

## Contributors
- Vibha Finaviya - Initial implementation

## License

This project is licensed under the [MIT License](LICENSE).
