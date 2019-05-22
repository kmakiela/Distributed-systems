import sys
import os
import Ice
sys.path.append(os.path.abspath("./utils/out/ice"))
from BankSystem import *


def get_currency_symbol(curr_str):
    switch = {
        'PLN': Currency.PLN,
        'GBP': Currency.GBP,
        'USD': Currency.USD,
        'CHF': Currency.CHF,
        'EUR': Currency.EUR
    }
    return switch.get(curr_str.upper(), 'invalid currency')


def cli_wr_rd(msg):
    sys.stdout.write(msg)
    sys.stdout.flush()
    return sys.stdin.readline().strip()


def run(communicator):
    server = AccountFactoryPrx.checkedCast(
        communicator.propertyToProxy('AccountFactory.Proxy').ice_twoway().ice_secure(False))
    if not server:
        print('invalid server proxy')
        sys.exit(1)

    account_proxy = None

    while True:
        if account_proxy is None:
            command = cli_wr_rd('bank_home >> ')
            if command == 'help':
                print('Available commands are: register, login, exit')
            elif command == 'register':
                name = cli_wr_rd('first_name >> ')
                surname = cli_wr_rd('surname >> ')
                pesel = cli_wr_rd('pesel >> ')
                balance = cli_wr_rd('starting balance >> ')
                try:
                    acc_create_resp = server.createAccount(Name(name),
                                                           Surname(surname),
                                                           Pesel(int(pesel)),
                                                           Balance(int(balance)))
                except Exception as error:
                    print(error)
                else:
                    print(acc_create_resp)
            elif command == 'login':
                pesel = cli_wr_rd('pesel >> ')
                password = cli_wr_rd('password >> ')
                ctx = {'password': password}
                try:
                    account_proxy = server.obtainAccess(Pesel(int(pesel)), ctx)
                except Exception as error:
                    print(error)
                else:
                    print(account_proxy)
            elif command == 'exit':
                sys.exit(0)
            elif command == '':
                continue
            else:
                print('invalid command, use \'help\'')
        else:
            sys.stdout.write('bank_{} >> '.format(account_proxy.getAccountType()))
            sys.stdout.flush()
            command = sys.stdin.readline().strip()
            if command == 'help':
                print('Available commands are: logout, balance, account_type, loan')
            elif command == 'logout':
                account_proxy = None
            elif command == 'balance':
                print('current balance is: {}'.format(account_proxy.getAccountBalance()))
            elif command == 'loan':
                loan_currency = cli_wr_rd('loan_currency >> ')
                loan_amount = cli_wr_rd('loan_amount >> ')
                loan_period = cli_wr_rd('loan_period >> ')
                try:
                    loan_estimate = account_proxy.applyForLoan(get_currency_symbol(loan_currency),
                                                                   Balance(int(loan_amount)),
                                                                   Period(loan_period))
                except Exception as error:
                    print(error)
                else:
                    print(loan_estimate)
            elif command == 'account_type':
                print('current account type is: {}'.format(account_proxy.getAccountType()))
            elif command == '':
                continue
            else:
                print('invalid command, use \'help\'')


with Ice.initialize(sys.argv, "./client/config.client") as communicator:
    run(communicator)
