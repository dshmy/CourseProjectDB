using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Oracle.ManagedDataAccess.Client;
using WpfApp2.DataBase;
using WpfApp2.Users;

namespace WpfApp2.Employee
{
    /// <summary>
    /// Логика взаимодействия для CreateContractWindow.xaml
    /// </summary>
    public partial class CreateContractWindow : Window
    {
        private CurrentEmployee currentEmployee;

        public CreateContractWindow(CurrentEmployee currentEmployee)
        {
            InitializeComponent();
            this.currentEmployee = currentEmployee;
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.employeeConn))
                {
                    connection.Open();
                    OracleParameter tariff = new OracleParameter
                    {
                        ParameterName = "tariff",
                        Direction = ParameterDirection.Output,
                        OracleDbType = OracleDbType.RefCursor
                    };

                    using (OracleCommand command = new OracleCommand("Administrator.getTariffs"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[] {tariff});
                        var reader = command.ExecuteReader();
                        DataTable dt = new DataTable();
                        dt.Load(reader);

                        foreach (DataRow row in dt.Rows)
                        {
                            tariffsText.Items.Add(row["Name"].ToString());
                        }
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void CreateContractWindow_OnLoaded(object sender, RoutedEventArgs e)
        {

        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                using (OracleConnection connection = new OracleConnection(OracleDatabaseConnection.employeeConn))
                {
                    connection.Open();

                    OracleParameter number = new OracleParameter
                    {
                        ParameterName = "in_number",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = phoneNumberText.Text
                    };
                    OracleParameter tariff = new OracleParameter
                    {
                        ParameterName = "in_tariff",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = tariffsText.Text
                    };
                    OracleParameter name = new OracleParameter
                    {
                        ParameterName = "in_name",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = nameText.Text
                    };
                    OracleParameter surname = new OracleParameter
                    {
                        ParameterName = "in_surname",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = surnameText.Text
                    };
                    OracleParameter secondname = new OracleParameter
                    {
                        ParameterName = "in_secondname",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = secondnameText.Text
                    };
                    OracleParameter passportnumber = new OracleParameter
                    {
                        ParameterName = "in_passportnumber",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = passportNumberText.Text
                    };
                    OracleParameter issuedby = new OracleParameter
                    {
                        ParameterName = "in_issuedby",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = issuedByText.Text
                    };
                    OracleParameter town = new OracleParameter
                    {
                        ParameterName = "in_town",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = townText.Text
                    };
                    OracleParameter street = new OracleParameter
                    {
                        ParameterName = "in_street",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = streetText.Text
                    };
                    OracleParameter buildingnumber = new OracleParameter
                    {
                        ParameterName = "in_buildingnumber",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.NVarchar2,
                        Value = buildingNumberText.Text
                    };
                    OracleParameter employeeid = new OracleParameter
                    {
                        ParameterName = "in_emplid",
                        Direction = ParameterDirection.Input,
                        OracleDbType = OracleDbType.Int32,
                        Value = currentEmployee.id
                    };

                    using (OracleCommand command = new OracleCommand("Administrator.addContract"))
                    {
                        command.Connection = connection;
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(new OracleParameter[]
                        {
                            number, tariff, name, surname, secondname, passportnumber, issuedby, town, street,
                            buildingnumber, employeeid
                        });
                        int r = command.ExecuteNonQuery();
                        MessageBox.Show("Добавление прошло успешно");
                    }
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}