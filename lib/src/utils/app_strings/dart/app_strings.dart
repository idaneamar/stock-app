/// Centralized strings for the application
/// Used for localization support and consistency
abstract class AppStrings {
  // App General
  static const String appName = 'Stock App';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String update = 'Update';
  static const String edit = 'Edit';
  static const String save = 'Save';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String clear = 'Clear';
  static const String value = 'Value';
  static const String refresh = 'Refresh';
  static const String loadMore = 'Load More';
  static const String noDataAvailable = 'No data available';
  static const String downloadExcel = 'Download Excel';
  static const String downloadStarted = 'Download started';

  // Home Screen
  static const String scanStocks = 'Scan Stocks';
  static const String stocksHome = 'Stocks Home';
  static const String deleteAllScans = 'Delete All Scans';
  static const String tapToScanStocks =
      'Tap the scan button to start stock scanning';
  /// Shown when scan history is empty; run scan is only from Strategies.
  static const String runScanFromStrategies =
      'Run a scan from the Strategies menu (left drawer)';
  static const String scanPrefix = 'Scan #';
  static const String stocksFound = 'stocks found';
  static const String scanning = 'Scanning:';
  static const String stockSymbols = 'Stock Symbols:';
  static const String andMore = '...and';
  static const String more = 'more';
  static const String tapToViewStocks = 'Tap to view stocks';
  static const String deleteScan = 'Delete Scan';
  static const String deleteScanConfirm =
      'Are you sure you want to delete Scan #';
  static const String actionCannotBeUndone = 'This action cannot be undone.';
  static const String deleteAllScansConfirm =
      'Are you sure you want to delete all scan history? This action cannot be undone.';
  static const String failedToDeleteScan = 'Failed to delete Scan #';
  static const String stockFilters = 'Stock Filters';
  static const String minMarketCap = 'Min Market Cap (M USD)';
  static const String maxMarketCap = 'Max Market Cap (M USD)';
  static const String minAvgVolume = 'Min Avg Volume (Shares)';
  static const String minAvgTransactionValue =
      'Min Avg Transaction Value (USD)';
  static const String minVolatility = 'Min Volatility';
  static const String minPrice = 'Min Price (USD)';
  static const String topNStocks = 'Top N Stocks';
  static const String useVixFilter = 'Use VIX filter';
  static const String useVixFilterHint =
      'When off, the scan ignores VIX/SPY market conditions.';
  static const String program = 'Program';
  static const String createProgram = 'Create Program';
  static const String programName = 'Program Name';
  static const String runScan = 'Run Scan';
  static const String runScanHint = 'Run a scan with the selected program';
  static const String selectProgram = 'Select Program';
  static const String programCreated = 'Program created successfully';
  static const String programCreateFailed = 'Failed to create program';
  static const String programNameRequired = 'Program name is required';
  static const String selectProgramToRun = 'Select a program to run';
  static const String scanStarted = 'Scan started';
  static const String scanStartFailed = 'Failed to start scan';
  static const String strictRules = 'Strict rules (hard filters)';
  static const String strictRulesHint =
      'When on, mandatory rules remove Buy/Sell signals instead of just lowering the score.';
  static const String adxMin = 'ADX minimum (optional)';
  static const String volumeSpikeRequired = 'Require Volume Spike';
  static const String dailyLossLimitPct = 'Daily loss limit (pct, e.g. 0.02)';
  static const String allowIntradayPrices = 'Use intraday price (best effort)';
  static const String invalidDate = 'Invalid date';
  static const String selectStrategies = 'Select Strategies';
  static const String loadingStrategies = 'Loading strategies...';
  static const String noEnabledStrategies = 'No enabled strategies';
  static const String strategiesSelectionHint =
      'If none selected, the scan will run with no strategies (HOLD / no trades).';

  // Trades Screen
  static const String openTrades = 'Open Trades';
  static const String closedTrades = 'Closed Trades';
  static const String allRecommendations = 'All Recommendations';
  static const String noOpenTradesFound = 'No open trades found';
  static const String noClosedTradesFound = 'No closed trades found';
  static const String noTradesFound = 'No Trades Found';
  static const String noTradesFoundForDateRange =
      'No trades found for the selected date range';
  static const String deleteOpenTrade = 'Delete Open Trade';
  static const String deleteTrade = 'Delete Trade';
  static const String deleteTradeConfirm =
      'Are you sure you want to delete the open trade for';
  static const String deleteTradeConfirmGeneric =
      'Are you sure you want to delete the trade for';
  static const String deletedSuccessfully = 'deleted successfully';
  static const String failedToDeleteTrade = 'Failed to delete trade';
  static const String editTrade = 'Edit Trade';
  static const String updateTrade = 'Update Trade';
  static const String updatedSuccessfully = 'updated successfully';
  static const String tradeUpdatedSuccessfully = 'Trade updated successfully';
  static const String failedToUpdateTrade = 'Failed to update trade';
  static const String errorUpdatingTrade = 'Error updating trade:';
  static const String errorDeletingTrade = 'Error deleting trade:';
  static const String deleting = 'Deleting';
  static const String updating = 'Updating';
  static const String exportOpenTrades = 'Export Open Trades';
  static const String importOpenTrades = 'Import Open Trades';
  static const String exportingTrades = 'Exporting trades...';
  static const String importingTrades = 'Importing trades...';
  static const String failedToExportTrades = 'Failed to export trades';
  static const String failedToReadFile = 'Failed to read file';
  static const String failedToImportTrades = 'Failed to import trades';
  static const String savedTo = 'Saved to:';
  static const String trades = 'trades';
  static const String results = 'Results';
  static const String suggestions = 'Suggestions';
  static const String noResultsFound = 'No results found';
  static const String noSuggestionsFound = 'No suggestions found';
  static const String totalInvestment = 'Total Investment:';

  // Trade Details
  static const String entryPrice = 'Entry Price';
  static const String stopLoss = 'Stop Loss';
  static const String takeProfit = 'Take Profit';
  static const String positionSize = 'Position Size';
  static const String quantity = 'Quantity';
  static const String totalValue = 'Total Value';
  static const String riskRewardRatio = 'Risk/Reward Ratio';
  static const String entryDate = 'Entry Date';
  static const String exitDate = 'Exit Date';
  static const String strategy = 'Strategy';
  static const String symbol = 'Symbol';
  static const String recommendation = 'Recommendation';
  static const String scanId = 'Scan ID:';
  static const String currentExitDate = 'Current Exit Date:';
  static const String newExitDate = 'New Exit Date:';
  static const String selectExitDate = 'Select exit date';

  // Date Filter
  static const String dateFilter = 'Date Filter';
  static const String selectDateRange = 'Select Date Range';
  static const String selectStartDate = 'Select Start Date';
  static const String selectEndDate = 'Select End Date';
  static const String pleaseSelectDateRangeFirst =
      'Please select a date range first';
  static const String downloadAllRecommendation = 'Download All Recommendation';

  // Excel/Downloads
  static const String excelFileDownloadedSuccessfully =
      'Excel file downloaded successfully!';
  static const String excelFileSavedToDownloadsFolder =
      'Excel file saved to Downloads folder:';
  static const String failedToDownloadExcelFile =
      'Failed to download Excel file';
  static const String failedToSaveExcelFile = 'Failed to save Excel file:';
  static const String errorDownloadingExcelFile =
      'Error downloading Excel file:';
  static const String loadingExcelData = 'Loading Excel data...';
  static const String noExcelDataAvailable = 'No Excel data available';
  static const String selectedSheetNotFound = 'Selected sheet not found';
  static const String noDataInSheet = 'No data in this sheet';

  // Settings Screen
  static const String settings = 'Settings';
  static const String appSettings = 'App Settings';
  static const String loadingSettings = 'Loading settings...';
  static const String noSettingsFound = 'No Settings Found';
  static const String unableToLoadSettings = 'Unable to load app settings';
  static const String managePreferences =
      'Manage your app preferences and configuration';
  static const String portfolioSize = 'Portfolio Size';
  static const String editSettings = 'Edit Settings';
  static const String updatingSettings = 'Updating Settings...';
  static const String updateSettings = 'Update Settings';

  // Strategies (Admin)
  static const String strategies = 'Strategies';
  static const String createStrategy = 'Create Strategy';
  static const String editStrategy = 'Edit Strategy';
  static const String noStrategiesFound = 'No strategies found';
  static const String strategyName = 'Name';
  static const String enabled = 'Enabled';
  static const String strategyRules = 'Rules';
  static const String strategyRulesHint =
      'Build rules using the supported indicators/operators. The app will generate config automatically.';
  static const String preFilters = 'Pre-filters';
  static const String preFiltersOptional =
      'Optional: applied first. If any pre-filter fails, no signal is produced.';
  static const String buyRules = 'Buy rules';
  static const String sellRules = 'Sell rules';
  static const String sellRulesOptional = 'Optional: add sell rules if needed.';
  static const String addRule = 'Add rule';
  static const String rule = 'Rule';
  static const String indicator = 'Indicator';
  static const String operator = 'Operator';
  static const String rightHandSide = 'Right-hand side';
  static const String compareTo = 'Compare to';
  static const String expression = 'Expression';
  static const String invalidExpression = 'Invalid expression';
  static const String strategyRulesInvalid =
      'Please fill all rules and risk fields correctly.';
  static const String risk = 'Risk';
  static const String stopLossAtrMult = 'Stop loss (ATR mult)';
  static const String takeProfitAtrMult = 'Take profit (ATR mult)';
  static const String minRiskReward = 'Min risk/reward';
  static const String strategyNameRequired = 'Name is required';
  static const String invalidJson = 'Invalid JSON. Please fix and try again.';
  static const String strategyCreated = 'Strategy created successfully';
  static const String strategyCreateFailed = 'Failed to create strategy';
  static const String strategyUpdated = 'Strategy updated successfully';
  static const String strategyUpdateFailed = 'Failed to update strategy';
  static const String strategyDeleteFailed = 'Failed to delete strategy';
  static const String deleteStrategyConfirm = 'Delete strategy';

  // Excel Viewer
  static const String excelParsingFailed = 'Excel Parsing Failed';
  static const String errorPrefix = 'Error:';
  static const String fileInformation = 'File Information';
  static const String fileSize = 'File Size';
  static const String bytes = 'bytes';
  static const String fileFormat = 'File Format';
  static const String firstBytes = 'First Bytes';
  static const String lastBytes = 'Last Bytes';
  static const String saveFile = 'Save File';
  static const String rawData = 'Raw Data';
  static const String suggestionsList = 'Suggestions';
  static const String suggestionRefresh =
      'Try refreshing the analysis and generating a new Excel file';
  static const String suggestionConnection =
      'Check your internet connection and try again';
  static const String suggestionSupport =
      'Contact support if the issue persists';
  static const String saveFileDialogTitle = 'Save File';
  static const String saveFileDialogContent =
      'This feature would normally allow you to save the Excel file to your device. '
      'However, since the file appears to be corrupted, please try generating a new analysis.';
  static const String rawDataDialogTitle = 'Raw Data (First 200 bytes)';
  static const String hexadecimal = 'Hexadecimal:';
  static const String zipBasedExcel = 'ZIP-based (Excel .xlsx)';
  static const String ole2Excel = 'OLE2 (Excel .xls)';
  static const String unknown = 'Unknown';
  static const String debugInfo = 'Debug Info';
  static const String openExcel = 'Open Excel';
  static const String totalTrades = 'Total Trades:';
  static const String scans = 'scans';
  static const String analyzedAt = 'Analyzed';
  static const String suggestionsInvestment = 'Suggestions Investment:';

  // Order Prepare
  static const String analysisOrderPrepare = 'Analysis Order Prepare';
  static const String failedToLoadOrderPreview = 'Failed to load order preview';
  static const String totalOrders = 'Total Orders:';
  static const String currentValue = 'Current Value';
  static const String noOrdersFound = 'No orders found';
  static const String noOrdersToPlace = 'There are no orders to place.';
  static const String placeOrder = 'Place Order';
  static const String placingOrder = 'Placing Order...';
  static const String orderPlacedSuccessfully = 'Order placed successfully!';
  static const String failedToPlaceOrder = 'Failed to place order';

  // Stock Analysis
  static const String analysis = 'Analysis';
  static const String limitedActiveRecommendation = 'All Recommendation';
  static const String downloadLimitedRecommendation =
      'Download Limited Recommendation';
  static const String noLimitedActiveTradesFound = 'No Trades Found';
  static const String failedToLoadScanData = 'Failed to load scan data';

  // Status Messages
  static const String completed = 'Completed';
  static const String inProgress = 'In Progress';
  static const String analyzing = 'Analyzing';
  static const String failed = 'Failed';
  static const String pending = 'Pending';

  // Error Messages
  static const String somethingWentWrong = 'Something went wrong';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unexpectedError = 'An unexpected error occurred';
  static const String receivedEmptyExcelData = 'Received empty Excel data';
  static const String unexpectedResponseDataType =
      'Unexpected response data type:';

  // Drawer Menu
  static const String menu = 'Menu';
  static const String home = 'Home';
  static const String allExcelFiles = 'All Excel Files';
  static const String drawerHomeSubtitle = 'Back to home screen';
  static const String drawerExcelSubtitle = 'View Excel reports';
  static const String drawerRecommendationsSubtitle =
      'View all recommendations';
  static const String drawerStrategiesSubtitle = 'Manage strategies';
  static const String drawerOpenTradesSubtitle = 'View active open trades';
  static const String drawerClosedTradesSubtitle = 'View closed trades';
  static const String drawerResetSubtitle = 'Clear all scans and trades';
  static const String drawerSettingsSubtitle = 'App preferences';
  static const String resetAllData = 'Reset All Data';
  static const String resetAllDataConfirm =
      'Are you sure you want to reset all data? This action cannot be undone.';
  static const String dataResetSuccessfully = 'Data reset successfully';
  static const String failedToResetData = 'Failed to reset data';
}
