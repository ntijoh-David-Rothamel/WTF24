beforeEach(() => {
  cy.visit('http://localhost:9292/test')
})

describe('login', () => {
  it('sucessful', () => {
    cy.visit('http://localhost:9292/users');

    cy.get('#name').type('admin')
    cy.get('#password').type('admin')

    cy.get('[type="submit"]').click()

    cy.location('pathname').should('eq', '/casinos')
  })

  it('it failed', () => {
    cy.visit('http://localhost:9292/users');

    cy.get('#name').type('admin')
    cy.get('#password').type('hippity')

    cy.get('[type="submit"]').click()

    cy.location('pathname').should('eq', '/users/failed')

    cy.get('#error').contains('Wrong username or password')
  })
})

describe('add user', () => {

  it('successful', () => {
    cy.visit('http://localhost:9292/users/new');

    cy.get('#name').type('linus')
    cy.get('#email').type('hippity@gmail.com')
    cy.get('#password').type('linus')
    cy.get('#re_password').type('linus')

    cy.get('[type="submit"]').click()

    cy.location('pathname').should('eq', '/users')
  })

  it('failed', () => {
    cy.visit('http://localhost:9292/users/new');

    cy.get('#name').type('linus')
    cy.get('#email').type('hippity@gmail.com')
    cy.get('#password').type('linus')
    cy.get('#re_password').type('linus')

    cy.get('[type="submit"]').click()
  })
})

describe('create casino', () => {
  it('sucessful', () => {
    cy.visit('http://localhost:9292/users');

    cy.get('#name').type('admin')
    cy.get('#password').type('admin')
    cy.get('[type="submit"]').click()

    cy.get('#layout_new_casino').click()

    cy.get('#casino_name').type('då var det dags igen')
    cy.get('#win_stats').type('2')
    cy.get('#turnover').type('3')
    cy.get('#logo_filepath').type('hippity')
    cy.get('#cats').type('test')

    cy.get('#create_casino').click()

    cy.get('#casino_name').should('have.value', 'då var det dags igen')
  })
})