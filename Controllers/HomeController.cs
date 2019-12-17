using SumoTech.Entity;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class HomeController : Controller
    {

        public List<Item> GetItems(int category)
        {
            List<Item> items = new List<Item>();
            string conString = ConfigurationManager.ConnectionStrings["dataConnection"].ConnectionString;
            SqlConnection connection = new SqlConnection(conString);
            try
            {
                connection.Open();
            }
            catch (Exception ex)
            {
                Response.Write("error" + ex.ToString());
                connection.Close();
                return null;
            }
            String command = "";

            if (category == 1)
            {
                command = "where item_type = Television";
            }
            else if (category == 2)
            {
                command = "where item_type = Computer Part";
            }

            else if (category == 3)
            {
                command = "where item_type = Basic Electronics";
            }

            else if (category == 4)
            {
                command = "where item_type = HouseHold Applience";
            }
            else
            {
                command = "";
            }

            string cmdString = "SELECT * FROM Item" + command;
            SqlCommand cmd = new SqlCommand(cmdString, connection);
            SqlDataReader nwReader = cmd.ExecuteReader();
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
                items.Add(item);
            }
            connection.Close();
            return items;
        }
        // GET: Home
        public ActionResult Index(string category)
        {
            int categoryid;
            if (category == null)
                categoryid = 0;
            else
            {
                categoryid = System.Convert.ToInt32(category);
            }

            return View(GetItems(categoryid).ToList());
        }
    }
}