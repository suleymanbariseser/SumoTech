using SumoTech.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class UserMain
    {
        DataContext dataContext;
        public UserMain()
        {
            dataContext = new DataContext();
        }
        public List<Customer> GetAllCustomers()
        {
            dataContext.OpenConnection();
            List<Customer> Customers = new List<Customer>();
            string cmd = "Select * from Customer";
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                Customer customer = new Customer();
                customer.Id = (int)sqlDataReader["customerid"];
                customer.FirstName = (string)sqlDataReader["first_name"];
                customer.LastName = (string)sqlDataReader["last_name"];
                customer.Phone = (string)sqlDataReader["Phone"];
                customer.Email = (string)sqlDataReader["Email"];
                Customers.Add(customer);
            }
            dataContext.CloseConnection();
            return Customers;
        }
        public Customer GetCustomer(int id)
        {
            Customer customer = new Customer();
            dataContext.OpenConnection();
            string cmd = "Select * from Customer WHERE customerid = " + id;
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                customer.Id = (int)sqlDataReader["customerid"];
                customer.FirstName = (string)sqlDataReader["first_name"];
                customer.LastName = (string)sqlDataReader["last_name"];
                customer.Phone = (string)sqlDataReader["Phone"];
                customer.Email = (string)sqlDataReader["Email"];
            }
            dataContext.CloseConnection();
            customer.OrderLine = GetOrderLines(id);
            customer.Address = GetCustomerAddress(id);
            return customer;
        }
        public List<OrderLine> GetOrderLines(int id)
        {
            dataContext.OpenConnection();
            List<OrderLine> orderLines = new List<OrderLine>();
            SqlCommand sql = new SqlCommand("CustomerOrders", dataContext.GetConnection());
            sql.CommandType = CommandType.StoredProcedure;
            sql.Parameters.AddWithValue("@customerid", id);
            SqlDataReader sqlDataReader = sql.ExecuteReader();
            while (sqlDataReader.Read())
            {
                OrderLine orderLine = new OrderLine();
                orderLine.Id = (int)sqlDataReader["orderlineid"];
                orderLine.Price = (double)sqlDataReader["order_price"];
                orderLine.Destination_address = (string)sqlDataReader["destination_address"];
                orderLine.Date = (DateTime)sqlDataReader["order_date"];
                orderLines.Add(orderLine);
            }
            dataContext.CloseConnection();
            return orderLines;
        }
        public List<Address> GetCustomerAddress(int id)
        {
            List<Address> Addresses = new List<Address>();
            dataContext.OpenConnection();
            string cmd = "SELECT * FROM CustomerAddress WHERE customerid = " + id;            
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                Address address = new Address();
                address.Id = (int)sqlDataReader["addressid"];
                address.Country = (string)sqlDataReader["country"];
                address.City = (string)sqlDataReader["city"];
                address.Address_ = (string)sqlDataReader["address_"];
                Addresses.Add(address);
            }
            dataContext.CloseConnection();
            return Addresses;
        }
        public bool CreateCustomer(string cmd, Customer customer)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@firstname", customer.FirstName);
                sql.Parameters.AddWithValue("@lastname", customer.LastName);
                sql.Parameters.AddWithValue("@phone", customer.Phone);
                sql.Parameters.AddWithValue("@email", customer.Email);
                dataContext.OpenConnection();
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
                return true;
            }
            catch
            {
                return false;
            }
        }
        public bool DeleteCustomer(int id)
        {
            string cmd = "Delete from Customer Where customerid = " + id;
            return dataContext.ExecuteQuery(cmd);
        }
        public bool UpdateCustomer(string cmd, Customer customer)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@firstname", customer.FirstName);
                sql.Parameters.AddWithValue("@lastname", customer.LastName);
                sql.Parameters.AddWithValue("@phone", customer.Phone);
                sql.Parameters.AddWithValue("@email", customer.Email);
                sql.Parameters.AddWithValue("@Id", customer.Id);
                dataContext.OpenConnection();
                sql.ExecuteNonQuery();
                dataContext.CloseConnection();
                return true;
            }
            catch
            {
                return false;
            }
        }
        public bool ExecuteQuery(string cmd)
        {
            return dataContext.ExecuteQuery(cmd);
        }
    }
}