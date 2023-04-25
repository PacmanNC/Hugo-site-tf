describe('Load website', () => {
  it('passes', () => {
    cy.visit(Cypress.env('TEST_URL'))
      .then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body).to.not.be.null
      })
  })
})

