using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SumoTech.Entity
{
    public class DataContext
    {
        string ConnectionString;
        SqlConnection Connection;

        public DataContext()
        {
            createConnection();
        }
        public void createConnection()
        {
            ConnectionString = ConfigurationManager.ConnectionStrings["dataConnection"].ConnectionString;
            Connection = new SqlConnection(ConnectionString);
        }

        public SqlDataReader Execute(string command)
        {
            SqlCommand sqlCommand = new SqlCommand(command, Connection);
            SqlDataReader sqlDataReader;
            try
            {
               sqlDataReader = sqlCommand.ExecuteReader();
            }
            catch
            {
                CloseConnection();
                return null;
            }
            return sqlDataReader;
        }
        public bool ExecuteQuery(string cmd)
        {
            try
            {
                SqlCommand sqlCommand = new SqlCommand(cmd, GetConnection());
                OpenConnection();
                sqlCommand.ExecuteNonQuery();
                CloseConnection();
                return true;
            }
            catch
            {
                return false;
            }
        }
        public SqlConnection GetConnection()
        {
            return Connection;
        }

        public SqlConnection OpenConnection()
        {
            try
            {
                Connection.Open();
            }
            catch
            {
                CloseConnection();
            }
            return Connection;
        }
        public void CloseConnection()
        {
            Connection.Close();
        }

    }
}