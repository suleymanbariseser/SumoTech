using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class ItemMain
    {
        protected DataContext dataContext;
        public ItemMain()
        {
            dataContext = new DataContext();
        }
        public List<Item> GetAllItems(int category)
        {
            List<Item> items = new List<Item>();
            dataContext.OpenConnection();
            String command;

            if (category == 1)
            {
                command = " WHERE item_type = 'Television'";
            }
            else if (category == 2)
            {
                command = " WHERE item_type = 'Computer Part'";
            }

            else if (category == 3)
            {
                command = " WHERE item_type = 'Basic Electronic'";
            }

            else if (category == 4)
            {
                command = " WHERE item_type = 'HouseHold Applience'";
            }
            else
            {
                command = "";
            }

            string cmdString = "SELECT * FROM Item ORDER BY itemid DESC" + command;
            SqlDataReader nwReader = dataContext.Execute(cmdString);
            while (nwReader.Read())
            {
                Item item = new Item();
                item.Id = (int)nwReader["itemid"];
                item.Brand = (string)nwReader["brand"];
                item.Name = (string)nwReader["name_"];
                item.Price = (double)nwReader["price"];
                item.Production_year = (int)nwReader["production_year"];
                item.Description = (string)nwReader["item_description"];
                item.Type = (string)nwReader["item_type"];
                if (item.Type == "Television")
                {
                    item.Image = "img1.jpg";
                }
                else if (item.Type == "Computer Part")
                    item.Image = "img2.jpg";

                else if (item.Type == "Basic Electronic")
                    item.Image = "img3.jpg";
                else if (item.Type == "HouseHold Applience")
                    item.Image = "img4.jpg";
                else
                    item.Image = "nophoto.png";
                items.Add(item);
            }
            nwReader.Close();
            dataContext.CloseConnection();
            return items;
        }
        public Item GetItem(int id)
        {
            Item item = new Item();
            dataContext.OpenConnection();
            string cmdString = "SELECT * FROM Item WHERE itemid = " + id;
            SqlDataReader nwReader = dataContext.Execute(cmdString);
            while (nwReader.Read())
            {
                item.Id = (int)nwReader["itemid"];
                item.Brand = (string)nwReader["brand"];
                item.Name = (string)nwReader["name_"];
                item.Price = (double)nwReader["price"];
                item.Production_year = (int)nwReader["production_year"];
                item.Description = (string)nwReader["item_description"];
                item.Type = (string)nwReader["item_type"];
            }
            dataContext.CloseConnection();
            return item;
        }
        public bool CreateItem(string cmd, Item item)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@brand", item.Brand);
                sql.Parameters.AddWithValue("@name", item.Name);
                sql.Parameters.AddWithValue("@price", item.Price);
                sql.Parameters.AddWithValue("@production_year", item.Production_year);
                sql.Parameters.AddWithValue("@description", item.Description);
                sql.Parameters.AddWithValue("@type", item.Type);
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
        public bool DeleteItem(int id)
        {
            try
            {
                string cmd = "Delete from Item Where itemid = " + id;
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
        public bool UpdateItem(string cmd, Item item)
        {
            try
            {
                SqlCommand sql = new SqlCommand(cmd, dataContext.GetConnection());
                sql.Parameters.AddWithValue("@brand", item.Brand);
                sql.Parameters.AddWithValue("@name", item.Name);
                sql.Parameters.AddWithValue("@price", item.Price);
                sql.Parameters.AddWithValue("@production_year", item.Production_year);
                sql.Parameters.AddWithValue("@description", item.Description);
                sql.Parameters.AddWithValue("@type", item.Type);
                sql.Parameters.AddWithValue("@Id", item.Id);
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