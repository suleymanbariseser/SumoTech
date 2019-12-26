using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class SupplierMain
    {
        DataContext dataContext;
        public SupplierMain()
        {
            dataContext = new DataContext();
        }
        public List<Supplier> GetAllSuppliers()
        {
            dataContext.OpenConnection();
            List<Supplier> Suppliers = new List<Supplier>();
            string cmd = "Select * from Supplier";
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                Supplier supplier = new Supplier();
                supplier.Id = (int)sqlDataReader["supplierid"];
                supplier.Name = (string)sqlDataReader["name_"];
                supplier.Country = (string)sqlDataReader["country"];
                supplier.City = (string)sqlDataReader["city"];
                supplier.Address = (string)sqlDataReader["address_"];
                supplier.Phone = (string)sqlDataReader["phone"];
                Suppliers.Add(supplier);
            }
            dataContext.CloseConnection();
            return Suppliers;
        }
        public Supplier GetSupplier(int id)
        {
            dataContext.OpenConnection();
            Supplier supplier = new Supplier();
            string cmd = "Select * from Supplier WHERE supplierid = " + id;
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                supplier.Id = (int)sqlDataReader["supplierid"];
                supplier.Name = (string)sqlDataReader["name_"];
                supplier.Country = (string)sqlDataReader["country"];
                supplier.City = (string)sqlDataReader["city"];
                supplier.Address = (string)sqlDataReader["address_"];
                supplier.Phone = (string)sqlDataReader["phone"];
            }
            dataContext.CloseConnection();
            return supplier;
        }
        public bool CreateSupplier(string cmd, Supplier supplier)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@name", supplier.Name);
                sql.Parameters.AddWithValue("@country", supplier.Country);
                sql.Parameters.AddWithValue("@city", supplier.City);
                sql.Parameters.AddWithValue("@address", supplier.Address);
                sql.Parameters.AddWithValue("@phone", supplier.Phone);
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
        public List<int> GetSupplierItems(int id)
        {
            List<int> itemids = new List<int>();
            dataContext.OpenConnection();
            SqlCommand sqlCommand = new SqlCommand("SuppliedItems", dataContext.GetConnection());
            sqlCommand.CommandType = CommandType.StoredProcedure;
            sqlCommand.Parameters.AddWithValue("@supplierid", id);
            SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
            while (sqlDataReader.Read())
            {
                itemids.Add((int)sqlDataReader["itemid"]);
            }
            dataContext.CloseConnection();
            return itemids;
        }
        public bool DeleteSupplier(int id)
        {
            try
            {
                string cmd = "Delete from Supplier Where supplierid = " + id;
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
        public bool UpdateSupplier(string cmd, Supplier supplier)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@name", supplier.Name);
                sql.Parameters.AddWithValue("@country", supplier.Country);
                sql.Parameters.AddWithValue("@city", supplier.City);
                sql.Parameters.AddWithValue("@address", supplier.Address);
                sql.Parameters.AddWithValue("@phone", supplier.Phone);
                sql.Parameters.AddWithValue("@Id", supplier.Id);
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