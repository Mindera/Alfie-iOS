import AlicerceAnalytics

public enum AnalyticsParameter: String, AnalyticsParameterKey {
    case productID = "product_id"
    case searchTerm = "search_term"
    case operationName = "operation_name"
    case httpStatus = "http_status"
    case graphqlErrorCode = "graphql_error_code"
    case retryCount = "retry_count"
    case errorCategory = "error_category"
}
