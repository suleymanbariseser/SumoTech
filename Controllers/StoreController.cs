using SumoTech.Entity;
using SumoTech.Models;
using System.Data.SqlClient;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class StoreController : Controller
    {
        StoreMain storeMain = new StoreMain();
        // GET: Store
        public ActionResult Home(int Id)
        {
            DataContext db = new DataContext();
            Store store;
            store = storeMain.GetStore(Id);
            store.Employees = storeMain.GetEmployees(Id);
            store.Items = storeMain.GetItems(Id);
            return View(store);
        }
        public ActionResult Edit(int id)
        {
            ViewBag.storeItems = storeMain.GetStoreItems(id);
            return View(storeMain.GetStore(id));
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Id,country,city,address,phone")] Store store)
        {
            if (ModelState.IsValid)
            {
                string cmd = "UPDATE Store SET country = @country, city = @city, address_ = @address, phone = @phone WHERE storeid = @Id";
                if (storeMain.UpdateStore(cmd, store) == true)
                {
                    return RedirectToAction("Store", "Admin");
                }
                else
                {
                    Response.Write("Failed!");
                }

            }
            return View();
        }
        
        public ActionResult Insert(int storeid,int itemid, int quantity)
        {
            StoreItem storeItem = new StoreItem();
            storeItem.Storeid = int.Parse(Request["storeid"]);
            storeItem.Itemid = int.Parse(Request["itemid"]);
            storeItem.Quantity = int.Parse(Request["quantity"]);
            string cmd = "INSERT INTO StoreItem (storeid, itemid, quantity) VALUES (@storeid, @itemid, @quantity)";
            storeMain.NewStoreItem(cmd, storeItem);
            return RedirectToAction("Edit", new { id = storeid});
        }
        public ActionResult Create()
        {
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "country,city,address,phone")] Store store)
        {
            if (ModelState.IsValid)
            {
                string cmd = "INSERT INTO Store (country, city, address_, phone)"
                    + " values (@country,@city,@address,@phone)";
                if (storeMain.CreateStore(cmd, store) == true) {
                    return RedirectToAction("Store", "Admin");
                }
                else
                {
                    Response.Write("Failed!");
                }
                
            }
            return View();
        }
        public ActionResult Delete(int id)
        {
            if(storeMain.DeleteStore(id) == true)
            {
                return RedirectToAction("Store", "Admin");
            }
            else
            {
                return View();
            }
        }
        public ActionResult DeleteItem(int storeid, int itemid)
        {
            string cmd = "DELETE FROM StoreItem WHERE storeid = @storeid AND itemid = @itemid";
            DataContext dataContext = new DataContext();
            SqlCommand sqlCommand = new SqlCommand(cmd, dataContext.GetConnection());
            sqlCommand.Parameters.AddWithValue("@storeid", storeid);
            sqlCommand.Parameters.AddWithValue("@itemid", itemid);
            dataContext.OpenConnection();
            sqlCommand.ExecuteNonQuery();
            dataContext.CloseConnection();
            return RedirectToAction("Edit", new { id = storeid});
        }
        public ActionResult Employee()
        {
            return View();
        }
    }
}