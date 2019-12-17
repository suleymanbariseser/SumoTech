using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Employee
    {
        public int Id { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Phone { get; set; }
        public String Email { get; set; }
        public List<String> Address { get; set; }
        public Store Store { get; set; }
        public Employee Manager { get; set; }
    }
}