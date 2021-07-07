.. _itertools-manual:

Resiliparse Itertools
=====================


Resiliparse Itertools are a collection of convenient and robust helper functions for iterating over data from unreliable sources using other tools from the Resiliparse toolkit.

Progress Loops
--------------
Progress loops are a convenience tool for iterating data with an active :class:`.TimeGuard` context. Since running a ``for`` loop in a :class:`.TimeGuard` with progress being reported after each iteration is a very common pattern, you can use the :func:`~.itertools.progress_loop` pass-through generator as a shortcut:

.. code-block:: python

  from time import sleep
  from resiliparse.itertools import progress_loop
  from resiliparse.process_guard import time_guard, ExecutionTimeout

  @time_guard(timeout=10)
  def foo():
      for _ in progress_loop(range(1000)):
          try:
              sleep(0.1)
          except ExecutionTimeout:
              break

  foo()

In cases where context auto-detection doesn't work, the active guard context can be passed to the generator via the ``ctx`` parameter:

.. code-block:: python

  with time_guard(timeout=10) as guard:
      for _ in progress_loop(range(1000), ctx=guard):
          try:
              sleep(0.1)
          except ExecutionTimeout:
              break

.. _itertools-exception-loops:

Exception Loops
---------------
Exception loops wrap an iterator to catch and return any exceptions raised while evaluating the input iterator.

This is primarily useful for unreliable generators that may throw unpredictably at any time  for unknown reasons (e.g., generators reading from a network data source). If you do not want to  wrap the entire loop in a ``try/except`` clause, you can use an :func:`~.itertools.exc_loop` to catch  any such exceptions and return them.

.. code-block:: python

  from resiliparse.itertools import exc_loop

  def throw_gen():
      from random import random
      for i in range(100):
          if random() <= 0.1:
              raise Exception('Random exception')
          yield i

  for val, exc in exc_loop(throw_gen()):
      if exc is not None:
          print('Exception raised:', exc)
          break

      print(val)

.. warning::

  Remember that a generator will end after throwing an exception, so if the input iterator is  a generator, you will have to create a new instance in order to retry or continue.

WARC Retry Loops
----------------
The WARC retry loop helper wraps a :class:`fastwarc.warc.ArchiveIterator` instance to retry in case of read failures.

.. note::

  :ref:`FastWARC <fastwarc-manual>` needs to be installed for this.

Use a WARC retry loop if the underlying stream is unreliable, such as when reading from a network data source. If an exception other than :exc:`StopIteration` is raised while consuming the iterator, the WARC reading process will be retried up to ``retry_count`` times. When a stream failure occurs,  the :class:`fastwarc.warc.ArchiveIterator` will be reinitialised with a new stream object by calling `stream_factory`. The new stream object returned by ``stream_factory()`` must be seekable.

.. code-block:: python

  from fastwarc.warc import ArchiveIterator
  from resiliparse.itertools import warc_retry

  def stream_factory():
      return open('warcfile.warc.gz', 'rb')

  for record in warc_retry(ArchiveIterator(stream_factory()), stream_factory, retry_count=3):
      pass