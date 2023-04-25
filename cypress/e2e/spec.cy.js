describe('Load website', () => {
  it('passes', () => {
    cy.visit(Cypress.env('TEST_URL'))
  })
})

