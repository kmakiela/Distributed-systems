import sys
import os
import Ice
import signal
import grpc
import random
import string
from threading import Thread
import threading
sys.path.append(os.path.abspath("./utils/out/proto"))
sys.path.append(os.path.abspath("./utils/out/ice"))
import exchange_pb2
import exchange_pb2_grpc
from BankSystem import *
from currency_rates import *


def connect_to_exchange(arg):
    channel = grpc.insecure_channel('localhost:50051')
    stub = exchange_pb2_grpc.ExchangeStub(channel)
    request = exchange_pb2.ExchangeRequest(currency_rates=arg)

    try:
        for response in stub.subscribeExchangeRate(request):
            currency_rates_print()
            currency_rates[response.currency] = response.ExchangeRate
    except Exception as e:
        print(e)


class AccountI(Account):
    def __init__(self, account_type, name, surname, pesel, password, income):
        self.account_type = account_type
        self.name = name
        self.surname = surname
        self.pesel = pesel
        self.password = password
        self.income = income
        self.balance = Balance(income.value)

    def getAccountType(self, current):
        print('Account type request for pesel: {}'.format(self.pesel))
        return self.account_type

    def getAccountBalance(self, current):
        print('Account balance request for pesel: {}'.format(self.pesel))
        return self.balance


class AccountStandardI(AccountI, AccountStandard):
    def applyForLoan(self, currency, amount, period, current):
        raise InvalidAccountTypeExceptionI


class AccountPremiumI(AccountI, AccountPremium):
    def applyForLoan(self, currency, amount, period, current):
        if currency.value not in currencies:
            raise CurrencyNotSupportedExceptionI
        credit_value = currency_rates[currency.value] * amount.value
        print('Loan has been approved')
        return LoanEstimate(amount, Balance(credit_value))


class AccountFactoryI(AccountFactory):
    def __init__(self):
        self.account_map = {}

    def createAccount(self, name, surname, pesel, income, current):
        password = Password('pass_' + random.choice(string.ascii_letters))
        if income.value > 1000:
            acc_type = AccountType.PREMIUM
            account = AccountPremiumI(acc_type, name, surname, pesel, password, income)
        else:
            acc_type = AccountType.STANDARD
            account = AccountStandardI(acc_type, name, surname, pesel, password, income)

        asm_id = str(pesel.value) + '_' + acc_type.name
        self.account_map[str(pesel.value) + password.value] = asm_id

        current.adapter.add(account, Ice.stringToIdentity(asm_id))
        print('The account {} has been created'.format(asm_id))
        return AccountCreated(password, account.account_type)

    def obtainAccess(self, pesel, current):
        try:
            asm_id = self.account_map[str(pesel.value) + current.ctx['password']]
            acc_prx = AccountPrx.checkedCast(current.adapter.createProxy(Ice.stringToIdentity(asm_id)))
        except Exception:
            raise InvalidCredentialsExceptionI
        else:
            print('Access to account {} has been obtained'.format(asm_id))
            return acc_prx


class InvalidAccountTypeExceptionI(InvalidAccountTypeException):
    pass


class InvalidCredentialsExceptionI(InvalidCredentialsException):
    pass


class CurrencyNotSupportedExceptionI(CurrencyNotSupportedException):
    pass


def exit_bank(signum, frame):
    for th in threading.enumerate():
        if th.is_alive():
            th._stop()
    communicator.shutdown()


with Ice.initialize(sys.argv, sys.argv[1]) as communicator:
    if __name__ == "__main__":
        currencies = list(map(lambda e: int(e), sys.argv[2:]))
        exchange_thread = Thread(target=connect_to_exchange, args=(currencies,))
        exchange_thread.start()

    signal.signal(signal.SIGINT, exit_bank)
    adapter = communicator.createObjectAdapter("AccountFactory")
    adapter.add(AccountFactoryI(), Ice.stringToIdentity("accountFactory"))
    adapter.activate()
    print('The server is active')
    communicator.waitForShutdown()
