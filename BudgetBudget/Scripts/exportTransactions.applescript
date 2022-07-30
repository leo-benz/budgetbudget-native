on exportTransactions(account, startDate)
  tell application "MoneyMoney" to export transactions from account account from date startDate as "plist"
end exportTransactions
