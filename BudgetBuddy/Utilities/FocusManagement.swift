import SwiftUI

enum TextFieldFocus: Hashable {
    case firstName
    case lastName
    case email
    case password
    case age
    case dependents
    case location
    case zipCode
    case monthlyNetIncome
    case maritalStatus
    case housing
    case transportation
    case carPayment
    case carInsurance
    case carMaintenance
    case groceries
    case subscriptions
    case otherExpenses
    case savings
    case dependentExpenses
}

extension View {
    func textFieldNextButton(
        focus: FocusState<TextFieldFocus?>.Binding,
        currentField: TextFieldFocus,
        nextField: TextFieldFocus?
    ) -> some View {
        self
            .submitLabel(nextField != nil ? .next : .done)
            .onSubmit {
                if let next = nextField {
                    focus.wrappedValue = next
                } else {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
    }
}
