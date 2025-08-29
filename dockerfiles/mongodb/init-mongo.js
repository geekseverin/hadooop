// Initialisation de la base de données MongoDB
db = db.getSiblingDB('bigdata');

// Création de la collection employees
db.createCollection('employees');

// Insertion de données d'exemple
db.employees.insertMany([
    {id: 1, name: "Alice", age: 25, city: "Paris", salary: 45000},
    {id: 2, name: "Bob", age: 30, city: "London", salary: 55000},
    {id: 3, name: "Charlie", age: 35, city: "New York", salary: 65000},
    {id: 4, name: "Diana", age: 28, city: "Berlin", salary: 50000},
    {id: 5, name: "Eve", age: 32, city: "Tokyo", salary: 60000}
]);

print("Base de données initialisée avec succès!");