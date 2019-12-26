using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class FactoryMain
    {
        DataContext dataContext;
        public FactoryMain()
        {
            dataContext = new DataContext();
        }
        public List<Factory> GetAllFactories()
        {
            dataContext.OpenConnection();
            List<Factory> Factories = new List<Factory>();
            string cmd = "Select * from Factory";
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                Factory factory = new Factory();
                factory.Id = (int)sqlDataReader["Factoryid"];
                factory.Country = (string)sqlDataReader["country"];
                factory.City = (string)sqlDataReader["city"];
                factory.Address = (string)sqlDataReader["address_"];
                factory.Capacity = (int)sqlDataReader["productionCapacity"];
                Factories.Add(factory);
            }
            dataContext.CloseConnection();
            return Factories;
        }
        public Factory GetFactory(int id)
        {
            Factory factory = new Factory();
            dataContext.OpenConnection();
            string cmd = "Select * FROM Factory WHERE factoryid = " + id;
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                factory.Id = (int)sqlDataReader["factoryid"];
                factory.Country = (string)sqlDataReader["country"];
                factory.City = (string)sqlDataReader["city"];
                factory.Address = (string)sqlDataReader["address_"];
                factory.Capacity = (int)sqlDataReader["productionCapacity"];
            }
            dataContext.CloseConnection();
            return factory;
        }
        public List<int> GetFactoryItems(int id)
        {
            List<int> Items = new List<int>();
            dataContext.OpenConnection();
            string cmd = "SELECT itemid FROM HouseholdApplience WHERE factoryid = " + id;
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                Items.Add((int)sqlDataReader["itemid"]);
            }
            dataContext.CloseConnection();
            return Items;
        }
        public bool CreateFactory(string cmd, Factory factory)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@country", factory.Country);
                sql.Parameters.AddWithValue("@city", factory.City);
                sql.Parameters.AddWithValue("@address", factory.Address);
                sql.Parameters.AddWithValue("@capacity", factory.Capacity);
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
        public bool DeleteFactory(int id)
        {
            try
            {
                string cmd = "Delete from Factory Where factoryid = " + id;
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
        public bool UpdateFactory(string cmd, Factory factory)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@country", factory.Country);
                sql.Parameters.AddWithValue("@city", factory.City);
                sql.Parameters.AddWithValue("@address", factory.Address);
                sql.Parameters.AddWithValue("@capacity", factory.Capacity);
                sql.Parameters.AddWithValue("@Id", factory.Id);
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