using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class EmployeeMain
    {
        DataContext dataContext;
        public EmployeeMain()
        {
            dataContext = new DataContext();
        }
        public List<Employee> GetAllEmployees()
        {
            dataContext.OpenConnection();
            List<Employee> Employees = new List<Employee>();
            string cmd = "Select * from Employee";
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                Employee employee = new Employee();
                employee.Id = (int)sqlDataReader["employeeid"];
                employee.FirstName = (string)sqlDataReader["first_name"];
                employee.LastName = (string)sqlDataReader["last_name"];
                employee.Phone = (string)sqlDataReader["Phone"];
                employee.Salary = (int)sqlDataReader["salary"];
                employee.HireTime = (DateTime)sqlDataReader["hire_date"];
                employee.StoreId = (int)sqlDataReader["Storeid"];
                Employees.Add(employee);
            }
            dataContext.CloseConnection();
            return Employees;
        }
        public Employee GetEmployee(int id)
        {
            dataContext.OpenConnection();
            Employee employee = new Employee();
            string cmd = "Select * from Employee";
            SqlDataReader sqlDataReader = dataContext.Execute(cmd);
            while (sqlDataReader.Read())
            {
                employee.Id = (int)sqlDataReader["employeeid"];
                employee.FirstName = (string)sqlDataReader["first_name"];
                employee.LastName = (string)sqlDataReader["last_name"];
                employee.Phone = (string)sqlDataReader["Phone"];
                employee.Salary = (int)sqlDataReader["salary"];
                employee.HireTime = (DateTime)sqlDataReader["hire_date"];
                employee.StoreId = (int)sqlDataReader["Storeid"];
                employee.ManagerId = sqlDataReader["Managerid"] == System.DBNull.Value ? default(int) : (int)sqlDataReader["Managerid"];
            }
            dataContext.CloseConnection();
            return employee;
        }
        public bool CreateEmployee(string cmd, Employee employee)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@first_name", employee.FirstName);
                sql.Parameters.AddWithValue("@last_name", employee.LastName);
                sql.Parameters.AddWithValue("@Phone", employee.Phone);
                sql.Parameters.AddWithValue("@salary", employee.Salary);
                sql.Parameters.AddWithValue("@storeid", employee.StoreId);
                sql.Parameters.AddWithValue("@hiretime", employee.HireTime);
                sql.Parameters.AddWithValue("@managerid", employee.ManagerId);
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
        public bool DeleteEmployee(int id)
        {
            try
            {
                string cmd = "Delete from Employee Where employeeid = " + id;
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
        public bool UpdateEmployee(string cmd, Employee employee)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@firstname", employee.FirstName);
                sql.Parameters.AddWithValue("@lastname", employee.LastName);
                sql.Parameters.AddWithValue("@phone", employee.Phone);
                sql.Parameters.AddWithValue("@salary", employee.Salary);
                sql.Parameters.AddWithValue("@hiretime", employee.HireTime);
                sql.Parameters.AddWithValue("@Id", employee.Id);
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