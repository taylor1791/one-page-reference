function main()
  local ignore = {2, 3, 5}
  local max = 10199
  local columns = 100
  local factors = createFactors(max)
  local partitions = partition(factors, 3, columns)

  for i = 1, #partitions do
    local table = {
      title = "Table " .. i,
      headers = createHeaders(partitions[i][(i - 1) * 100], ignore),
      rows = createRows(partitions[i], ignore),
    }

    printTable(table)
  end
end

function createFactors(max)
  local primes = createPrimes(max)
  local n = { min = 0, max = max }

  for i = 0, max do
    n[i] = nil

    for _, p in pairs(primes) do
      if i ~= p and i % p == 0 and n[i] == nil then
        n[i] = p
      end
    end
  end

  return n
end

function createPrimes (max)
  local sieve = {}
  local primes = {}

  for i = 2, math.sqrt(max) do
    if sieve[i] == nil then
      sieve[i] = true
      primes[#primes + 1] = i
    end

    for j = 2 * i, max, i do
      sieve[j] = false
    end
  end

  return primes
end

function partition (factors, nPartitions, columns)
  local partitions = {}

  for i = 1, nPartitions do
    partitions[i] = { rows = {} }
  end

  for i = factors["min"], factors["max"] do
    local n = i // columns % nPartitions + 1
    local partition = partitions[n]

    local row = i // columns * columns
    if partition[row] == nil then
      partition[row] = { min = row, max = row + columns - 1 }
    end

    if partition["rows"][#partition["rows"]] ~= row then
      partition["rows"][#partition["rows"] + 1] = row
    end

    partition[row][i] = factors[i]
  end

  return partitions
end

function createHeaders (table, ignoreList)
  local headers = {}

  for n = table["min"], table["max"] do
    if not shouldIgnore(n, ignoreList) then
      headers[#headers + 1] = n % (table["max"] - table["min"] + 1)
    end
  end

  return headers
end

function createRows (table, ignoreList)
  local rows = {}

  for _, row in pairs(table["rows"]) do
    rows[#rows + 1] = createRow(table[row], ignoreList)
  end

  return rows
end

function createRow(row, ignoreList)
  local values = { row["min"] }

  for n = row["min"], row["max"] do
    if not shouldIgnore(n, ignoreList) then
      values[#values + 1] = row[n] and row[n] or '..'
    end
  end

  return values
end

function shouldIgnore (n, ignoreList)
  for i = 1, #ignoreList do
    if n % ignoreList[i] == 0 then
      return true
    end
  end

  return false
end

function printTable (table)
  printTitle(table["title"])
  printTableHeader(table["headers"])
  printTableRows(table["rows"])
  printTableFooter()
end

function printTitle (title)
  tex.print('\\subsubsection*{' .. title .. '}')
end

function printTableHeader (headers)
  local groups = headerGroups(#headers)

  local alignment = ''
  for i = 1, #groups do
    alignment = alignment .. '|' .. string.rep('Y', groups[i])
  end

  tex.print('\\begin{tabularx}{\\linewidth}{|r' .. alignment .. '|}')
  tex.print('\\hline')
  tex.print('  & ' .. table.concat(headers, ' & ') .. '\\\\')
  tex.print('\\hline')
end

function headerGroups (n)
  if n < 7 then
    return { n }
  end

  if n < 10 then
    return headerGroupsOfSize (n, n // 2)
  end

  return headerGroupsOfSize (n, 5)
end

function headerGroupsOfSize (n, size)
  local groups = {}

  for i = 1, n // 5 do
    groups[#groups + 1] = 5
  end

  for i = #groups * 5, (n - 1) do
    local g = i % #groups + 1
    groups[g] = groups[g] + 1
  end

  return groups
end

function printTableRows (rows)
  for i = 1, #rows do
    tex.print(table.concat(rows[i], ' & ') .. '\\\\')
    tex.print(i % 3 == 0 and '[1.5ex]' or '')
  end
end

function printTableFooter ()
  tex.print('\\hline')
  tex.print('\\end{tabularx}')
end

main ()
