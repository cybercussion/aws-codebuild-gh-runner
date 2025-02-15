const request = require("supertest");
const app = require("../src/index"); // Import the Express app

describe("Service B API Tests", () => {
  it("should return a welcome message", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("message", "Hello from Service B!");
  });

  it("should return a health check response", async () => {
    const res = await request(app).get("/health");
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("status", "healthy");
  });
});