using SumoTech.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class StoreMain
    {
        DataContext dataContext;
        public StoreMain()
        {
            dataContext = new DataContext();
        }
        public List<Store> GetAllStores()
        {
            dataContext.OpenConnection();
            List<Store> Stores = new List<Store>();
            string cmd = "Select * from Store";
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                Store store = new Store();
                store.Id = (int)sqlDataReader["storeid"];
                store.Country = (string)sqlDataReader["country"];
                store.City = (string)sqlDataReader["city"];
                store.Phone = (string)sqlDataReader["phone"];
                store.Address = (string)sqlDataReader["address_"];
                Stores.Add(store);
            }
            dataContext.CloseConnection();
            return Stores;
        }
        public Store GetStore(int id)
        {
            Store store = new Store();
            dataContext.OpenConnection();
            string cmd = "Select * from Store WHERE storeid = " + id;
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                store.Id = (int)sqlDataReader["storeid"];
                store.Country = (string)sqlDataReader["country"];
                store.City = (string)sqlDataReader["city"];
                store.Phone = (string)sqlDataReader["phone"];
                store.Address = (string)sqlDataReader["address_"];
            }
            dataContext.CloseConnection();
            store.Items = GetItems(store.Id);
            store.Employees = GetEmployees(store.Id);
            return store;
        }
        public List<StoreItem> GetStoreItems(int id)
        {
            List<StoreItem> storeItems = new List<StoreItem>();
            dataContext.OpenConnection();
            string cmd = "SELECT * FROM StoreItem WHERE storeid = " + id;
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                StoreItem storeitem = new StoreItem();
                storeitem.Storeid = (int)sqlDataReader["storeid"];
                storeitem.Itemid = (int)sqlDataReader["itemid"];
                storeitem.Quantity = (int)sqlDataReader["quantity"];
                storeItems.Add(storeitem);
            }
            dataContext.CloseConnection();
            return storeItems;
        }
        public List<Employee> GetEmployees(int id)
        {
            dataContext.OpenConnection();
            List<Employee> employees = new List<Employee>();
            SqlCommand sql = new SqlCommand("StoreEmployees", dataContext.GetConnection());
            sql.CommandType = CommandType.StoredProcedure;
#pragma warning disable CS0618 // Tür veya üye artık kullanılmıyor
            sql.Parameters.Add("@storeid", id);
#pragma warning restore CS0618 // Tür veya üye artık kullanılmıyor
            SqlDataReader sqlDataReader = sql.ExecuteReader();

            while (sqlDataReader.Read())
            {
                Employee employee = new Employee();
                employee.Id = (int)sqlDataReader["employeeid"];
                employee.StoreId = (int)sqlDataReader["storeid"];
                employee.FirstName = (string)sqlDataReader["first_name"];
                employee.LastName = (string)sqlDataReader["last_name"];
                employee.Phone = (string)sqlDataReader["phone"];
                employee.Salary = (int)sqlDataReader["salary"];
                employee.HireTime = (DateTime)sqlDataReader["hire_date"];
                //     employee.ManagerId = (int)sqlDataReader["Managerid"];
                employees.Add(employee);
            }
            dataContext.CloseConnection();
            return employees;
        }
        public List<Item> GetItems(int id)
        {
            dataContext.OpenConnection();
            List<Item> items = new List<Item>();
            SqlCommand sql = new SqlCommand("StoreItems", dataContext.GetConnection());
            sql.CommandType = CommandType.StoredProcedure;
#pragma warning disable CS0618 // Tür veya üye artık kullanılmıyor
            sql.Parameters.Add("@storeid", id);
#pragma warning restore CS0618 // Tür veya üye artık kullanılmıyor
            SqlDataReader sqlDataReader = sql.ExecuteReader();

            while (sqlDataReader.Read())
            {
                Item item = new Item();
                item.Id = (int)sqlDataReader["itemid"];
                item.Brand = (string)sqlDataReader["brand"];
                item.Name = (string)sqlDataReader["name_"];
                item.Price = (double)sqlDataReader["price"];
                item.Production_year = (int)sqlDataReader["production_year"];
                item.Description = (string)sqlDataReader["item_description"];
                item.Type = (string)sqlDataReader["item_type"];
                items.Add(item);
            }
            dataContext.CloseConnection();
            return items;
        }
        public bool NewStoreItem(string cmd, StoreItem storeitem)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@storeid", storeitem.Storeid);
                sql.Parameters.AddWithValue("@itemid", storeitem.Itemid);
                sql.Parameters.AddWithValue("@Quantity", storeitem.Quantity);
                dataContext.OpenConnection();
                sql.ExecuteNonQuery();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public bool CreateStore(string cmd, Store store)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@country", store.Country);
                sql.Parameters.AddWithValue("@city", store.City);
                sql.Parameters.AddWithValue("@address", store.Address);
                sql.Parameters.AddWithValue("@phone", store.Phone);
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
        public bool DeleteStore(int id)
        {
            try
            {
                string cmd = "DELETE FROM Store WHERE storeid = " + id;
                SqlCommand sqlCommand = new SqlCommand(cmd, dataContext.GetConnection());
                dataContext.OpenConnection();
                sqlCommand.ExecuteNonQuery();
                dataContext.CloseConnection();
                return true;
            }
            catch
            {
                return false;
            }
        }
        public bool UpdateStore(string cmd, Store store)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@country", store.Country);
                sql.Parameters.AddWithValue("@city", store.City);
                sql.Parameters.AddWithValue("@address", store.Address);
                sql.Parameters.AddWithValue("@phone", store.Phone);
                sql.Parameters.AddWithValue("@Id", store.Id);
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
    }
}