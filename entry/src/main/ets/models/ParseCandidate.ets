export interface ParseCandidate {
  amount?: number
  amountCandidates?: number[]
  merchant?: string
  paymentMethod?: string
  paidAt?: string
  categorySuggestion?: string
  confidence: number
  warnings: string[]
  shouldConfirmManually: boolean
}
