null

### @ngInject ###
global.cobudgetApp.factory 'Currencies', (Records) ->
  ->
      [{ code: 'USD', symbol: '$' },
      { code: 'NZD', symbol: '$' },
      { code: 'CAD', symbol: '$' },
      { code: 'GBP', symbol: '£' },
      { code: 'EUR', symbol: '€' },
      { code: 'CHF', symbol: 'CHF' },
      { code: 'JPY', symbol: '¥' },
      { code: 'XBT', symbol: 'Ƀ' },
      { code: 'ETH', symbol: 'Ξ' }]
