using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Employee
    {
        [Required]
        public int Id { get; set; }
        [Required]
        public String FirstName { get; set; }
        [Required]
        public String LastName { get; set; }
        [Required]
        public String Phone { get; set; }
        [Required]
        public int Salary { get; set; }
        [Required]
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        public DateTime HireTime { get; set; }
        [Required]
        public int StoreId { get; set; }
        [Key]
        [ForeignKey("Employee")]
        public int? ManagerId { get; set; }
    }
}