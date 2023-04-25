describe('site loading', () => {
  it('passes', () => {
    cy.visit(Cypress.env('API_URL'))
    expect(response.status).to.eq(200)
  })
})
