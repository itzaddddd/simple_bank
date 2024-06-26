package util

const (
	USD = "USD"
	EUR = "EUR"
	THB = "THB"
	YEN = "YEN"
)

func IsSupportCurrency(currency string) bool {
	switch currency {
	case USD, EUR, THB, YEN:
		return true
	default:
		return false
	}
}
