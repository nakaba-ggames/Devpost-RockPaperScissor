export class ApiError extends Error {
  constructor(public status: number, public code: string, message: string, public retryable = false) {
    super(message);
  }
}

export function badRequest(message: string): never {
  throw new ApiError(400, 'INVALID_REQUEST', message);
}
